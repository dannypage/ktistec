require "../spec_helper"

Spectator.describe HomeController do
  before_each { Balloon.database.exec "BEGIN TRANSACTION" }
  after_each { Balloon.database.exec "ROLLBACK" }

  let(username) { random_string }
  let(password) { random_string }

  context "on step 1 (set host)" do
    before_each { Balloon.clear_host }
    after_each { Balloon.host = "https://test.test" }

    describe "GET /" do
      it "renders a form" do
        headers = HTTP::Headers{"Accept" => "text/html"}
        get "/", headers
        expect(response.status_code).to eq(200)
        expect(XML.parse_html(response.body).xpath_nodes("//form[.//input[@name='host']]")).not_to be_empty
      end

      it "returns a template" do
        headers = HTTP::Headers{"Accept" => "application/json"}
        get "/", headers
        expect(response.status_code).to eq(200)
        expect(JSON.parse(response.body).as_h.keys).to have("host")
      end
    end

    describe "POST /" do
      it "rerenders if params are invalid" do
        headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded", "Accept" => "text/html"}
        body = "host=foo_bar"
        post "/", headers, body
        expect(response.status_code).to eq(200)
        expect(XML.parse_html(response.body).xpath_nodes("//form/div[contains(@class,'error message')]/div").first.text).to match(/scheme must be present/)
      end

      it "rerenders if params are invalid" do
        headers = HTTP::Headers{"Content-Type" => "application/json"}
        body = {host: "foo_bar"}.to_json
        post "/", headers, body
        expect(response.status_code).to eq(200)
        expect(JSON.parse(response.body)["msg"]).to match(/scheme must be present/)
      end

      it "sets host and redirects" do
        headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded", "Accept" => "text/html"}
        body = "host=https://foo_bar"
        expect{post "/", headers, body}.to change{Balloon.host?}
        expect(response.status_code).to eq(302)
        expect(response.headers.to_a).to have({"Location", ["/"]})
      end

      it "sets host and redirects" do
        headers = HTTP::Headers{"Content-Type" => "application/json"}
        body = {host: "https://foo_bar"}.to_json
        expect{post "/", headers, body}.to change{Balloon.host?}
        expect(response.status_code).to eq(302)
        expect(response.headers.to_a).to have({"Location", ["/"]})
      end
    end
  end

  context "on step 2 (create account)" do
    describe "GET /" do
      it "renders a form" do
        headers = HTTP::Headers{"Accept" => "text/html"}
        get "/", headers
        expect(response.status_code).to eq(200)
        expect(XML.parse_html(response.body).xpath_nodes("//form[.//input[@name='username']][.//input[@name='password']][.//input[@name='name']][.//input[@name='summary']]")).not_to be_empty
      end

      it "returns a template" do
        headers = HTTP::Headers{"Accept" => "application/json"}
        get "/", headers
        expect(response.status_code).to eq(200)
        expect(JSON.parse(response.body).as_h.keys).to have("username", "password", "name", "summary")
      end
    end

    describe "POST /" do
      it "redirects if params are missing" do
        headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded", "Accept" => "text/html"}
        post "/", headers
        expect(response.status_code).to eq(302)
        expect(response.headers.to_a).to have({"Location", ["/"]})
      end

      it "redirects if params are missing" do
        headers = HTTP::Headers{"Content-Type" => "application/json"}
        post "/", headers
        expect(response.status_code).to eq(302)
        expect(response.headers.to_a).to have({"Location", ["/"]})
      end

      it "rerenders if params are invalid" do
        headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded", "Accept" => "text/html"}
        body = "username=&password=a1!&name=&summary="
        post "/", headers, body
        expect(response.status_code).to eq(200)
        expect(XML.parse_html(response.body).xpath_nodes("//form/div[contains(@class,'error message')]/div").first.text).to match(/username is too short, password is too short/)
      end

      it "rerenders if params are invalid" do
        headers = HTTP::Headers{"Content-Type" => "application/json"}
        body = {username: "", password: "a1!", name: "", summary: ""}.to_json
        post "/", headers, body
        expect(response.status_code).to eq(200)
        expect(JSON.parse(response.body)["msg"]).to match(/username is too short, password is too short/)
      end

      it "creates account and redirects" do
        headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded", "Accept" => "text/html"}
        body = "username=#{username}&password=#{password}&name=&summary="
        expect{post "/", headers, body}.to change{Account.count}.by(1)
        expect(response.status_code).to eq(302)
        expect(response.headers["Set-Cookie"]).to be_truthy
      end

      it "also creates actor" do
        headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded", "Accept" => "text/html"}
        body = "username=#{username}&password=#{password}&name=&summary="
        expect{post "/", headers, body}.to change{ActivityPub::Actor.count}.by(1)
      end

      it "creates account" do
        headers = HTTP::Headers{"Content-Type" => "application/json"}
        body = {username: username, password: password, name: "", summary: ""}.to_json
        expect{post "/", headers, body}.to change{Account.count}.by(1)
        expect(response.status_code).to eq(200)
        expect(JSON.parse(response.body)["jwt"]).to be_truthy
      end

      it "also creates actor" do
        headers = HTTP::Headers{"Content-Type" => "application/json"}
        body = {username: username, password: password, name: "", summary: ""}.to_json
        expect{post "/", headers, body}.to change{ActivityPub::Actor.count}.by(1)
      end
    end
  end

  context "when requesting the home page" do
    let!(account) { register(username, password) }

    context "if unauthenticated" do
      describe "GET /" do
        it "renders a list of local actors" do
          headers = HTTP::Headers{"Accept" => "text/html"}
          get "/", headers
          expect(response.status_code).to eq(200)
          expect(XML.parse_html(response.body).xpath_nodes("//a[contains(@class,'card')][contains(@href,'#{username}')]/@href").map(&.text)).to have(/\/actors\/#{username}/)
        end

        it "renders a list of local actors" do
          headers = HTTP::Headers{"Accept" => "application/json"}
          get "/", headers
          expect(response.status_code).to eq(200)
          expect(JSON.parse(response.body)["items"].as_a).to have(/\/actors\/#{username}/)
        end
      end
    end

    context "if authenticated" do
      sign_in(as: account.username)

      describe "GET /" do
        it "redirects to the user's page" do
          headers = HTTP::Headers{"Accept" => "text/html"}
          get "/", headers
          expect(response.status_code).to eq(302)
          expect(response.headers.to_a).to have({"Location", ["/actors\/#{username}"]})
        end

        it "redirects to the user's page" do
          headers = HTTP::Headers{"Accept" => "application/json"}
          get "/", headers
          expect(response.status_code).to eq(302)
          expect(response.headers.to_a).to have({"Location", ["/actors\/#{username}"]})
        end
      end
    end

    describe "POST /" do
      it "returns 404" do
        post "/"
        expect(response.status_code).to eq(404)
      end

      it "returns 404" do
        post "/"
        expect(response.status_code).to eq(404)
      end
    end
  end
end
