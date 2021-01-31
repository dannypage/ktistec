require "../../src/controllers/outboxes"
require "../../src/models/activity_pub/object/note"

require "../spec_helper/controller"
require "../spec_helper/network"

Spectator.describe RelationshipsController do
  setup_spec

  describe "POST /actors/:username/outbox" do
    let(actor) { register(with_keys: true).actor }
    let(other) { register(with_keys: true).actor }

    let(headers) { HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded", "Accept" => "text/html"} }

    it "returns 401 if not authorized" do
      post "/actors/0/outbox", headers
      expect(response.status_code).to eq(401)
    end

    context "when authorized" do
      sign_in(as: actor.username)

      it "returns 404 if not found" do
        post "/actors/0/outbox", headers
        expect(response.status_code).to eq(404)
      end

      it "returns 403 if not the current account" do
        post "/actors/#{other.username}/outbox", headers
        expect(response.status_code).to eq(403)
      end

      it "returns 400 if activity type is not supported" do
        post "/actors/#{actor.username}/outbox", headers, "type=FooBar"
        expect(response.status_code).to eq(400)
      end

      context "on announce" do
        before_each do
          actor.assign(followers: "#{actor.iri}/followers").save
        end

        it "returns 400 if the object iri is missing" do
          post "/actors/#{actor.username}/outbox", headers, "type=Announce"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if object does not exist" do
          post "/actors/#{actor.username}/outbox", headers, "type=Announce&object=https://remote/objects/blah_blah"
          expect(response.status_code).to eq(400)
        end

        let(object) do
          ActivityPub::Object.new(
            iri: "https://remote/objects/#{random_string}",
            attributed_to: other
          ).save
        end

        it "redirects when successful" do
          post "/actors/#{actor.username}/outbox", headers, "type=Announce&object=#{URI.encode_www_form(object.iri)}"
          expect(response.status_code).to eq(302)
        end

        it "creates an announce activity" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Announce&object=#{URI.encode_www_form(object.iri)}"}.
            to change{ActivityPub::Activity::Announce.count(actor_iri: actor.iri)}.by(1)
        end

        it "creates a visible activity if public" do
          post "/actors/#{actor.username}/outbox", headers, "type=Announce&object=#{URI.encode_www_form(object.iri)}&public=true"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).visible).to be_true
        end

        it "addresses (to) the public collection" do
          post "/actors/#{actor.username}/outbox", headers, "type=Announce&object=#{URI.encode_www_form(object.iri)}&public=true"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).to).to contain("https://www.w3.org/ns/activitystreams#Public")
        end

        it "addresses (to) the object's actor" do
          post "/actors/#{actor.username}/outbox", headers, "type=Announce&object=#{URI.encode_www_form(object.iri)}"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).to).to contain(other.iri)
        end

        it "addresses (cc) the actor's followers collection" do
          post "/actors/#{actor.username}/outbox", headers, "type=Announce&object=#{URI.encode_www_form(object.iri)}"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).cc).to contain(actor.followers)
        end

        it "puts the activity in the actor's outbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Announce&object=#{URI.encode_www_form(object.iri)}"}.
            to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
        end

        it "puts the activity in the other's inbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Announce&object=#{URI.encode_www_form(object.iri)}"}.
            to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
        end
      end

      context "on like" do
        before_each do
          actor.assign(followers: "#{actor.iri}/followers").save
        end

        it "returns 400 if the object iri is missing" do
          post "/actors/#{actor.username}/outbox", headers, "type=Like"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if object does not exist" do
          post "/actors/#{actor.username}/outbox", headers, "type=Like&object=https://remote/objects/blah_blah"
          expect(response.status_code).to eq(400)
        end

        let(object) do
          ActivityPub::Object.new(
            iri: "https://remote/objects/#{random_string}",
            attributed_to: other
          ).save
        end

        it "redirects when successful" do
          post "/actors/#{actor.username}/outbox", headers, "type=Like&object=#{URI.encode_www_form(object.iri)}"
          expect(response.status_code).to eq(302)
        end

        it "creates a like activity" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Like&object=#{URI.encode_www_form(object.iri)}"}.
            to change{ActivityPub::Activity::Like.count(actor_iri: actor.iri)}.by(1)
        end

        it "creates a visible activity if public" do
          post "/actors/#{actor.username}/outbox", headers, "type=Like&object=#{URI.encode_www_form(object.iri)}&public=true"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).visible).to be_true
        end

        it "addresses (to) the public collection" do
          post "/actors/#{actor.username}/outbox", headers, "type=Like&object=#{URI.encode_www_form(object.iri)}&public=true"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).to).to contain("https://www.w3.org/ns/activitystreams#Public")
        end

        it "addresses (to) the object's actor" do
          post "/actors/#{actor.username}/outbox", headers, "type=Like&object=#{URI.encode_www_form(object.iri)}"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).to).to contain(other.iri)
        end

        it "addresses (cc) the actor's followers collection" do
          post "/actors/#{actor.username}/outbox", headers, "type=Like&object=#{URI.encode_www_form(object.iri)}"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).cc).to contain(actor.followers)
        end

        it "puts the activity in the actor's outbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Like&object=#{URI.encode_www_form(object.iri)}"}.
            to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
        end

        it "puts the activity in the other's inbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Like&object=#{URI.encode_www_form(object.iri)}"}.
            to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
        end
      end

      context "on create" do
        let!(relationship) do
          Relationship::Social::Follow.new(
            actor: other,
            object: actor,
            confirmed: true
          ).save
        end

        before_each do
          actor.assign(followers: "#{actor.iri}/followers").save
        end

        it "returns 400 if the content is missing" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create"
          expect(response.status_code).to eq(400)
        end

        it "redirects when successful" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test"
          expect(response.status_code).to eq(302)
        end

        let(created) do
          ActivityPub::Object.find(attributed_to_iri: actor.iri)
        end

        it "redirects to the object view" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test"
          expect(response.headers["Location"]).to eq("/remote/objects/#{created.id}")
        end

        let(topic) do
          ActivityPub::Object.new(
            iri: "https://remote/objects/#{random_string}"
          ).save
        end

        it "redirects to the threaded view" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&in-reply-to=#{URI.encode_www_form(topic.iri)}"
          expect(response.headers["Location"]).to eq("/remote/objects/#{topic.id}/thread#object-#{topic.id}")
        end

        it "creates a create activity" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test"}.
            to change{ActivityPub::Activity::Create.count(actor_iri: actor.iri)}.by(1)
        end

        it "creates a note object" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test"}.
            to change{ActivityPub::Object::Note.count(attributed_to_iri: actor.iri)}.by(1)
        end

        context "when a draft object is specified" do
          let(object) do
            ActivityPub::Object.new(
              iri: "https://test.test/objects/#{random_string}",
              attributed_to: actor
            ).save
          end

          pre_condition { expect(object.draft?).to be_true }

          it "creates a create activity" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"}.
              to change{ActivityPub::Activity::Create.count(actor_iri: actor.iri)}.by(1)
          end

          it "does not create an object" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"}.
              not_to change{ActivityPub::Object.count(attributed_to_iri: actor.iri)}
          end

          it "does not change the iri" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"}.
              not_to change{ActivityPub::Object.find(attributed_to_iri: actor.iri).iri}
          end

          it "changes the published timestamp" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"}.
              to change{ActivityPub::Object.find(attributed_to_iri: actor.iri).published}
          end

          it "returns 400 if object does not exist" do
            post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=http://test.test/does-not-exist"
            expect(response.status_code).to eq(400)
          end

          it "returns 403 if attributed to another account" do
            object.assign(attributed_to: other).save
            post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"
            expect(response.status_code).to eq(403)
          end
        end

        context "when a published object is specified" do
          let(object) do
            ActivityPub::Object.new(
              iri: "https://test.test/objects/#{random_string}",
              attributed_to: actor,
              published: Time.utc
            ).save
          end

          pre_condition { expect(object.draft?).to be_false }

          it "creates an update activity" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"}.
              to change{ActivityPub::Activity::Update.count(actor_iri: actor.iri)}.by(1)
          end

          it "does not create an object" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"}.
              not_to change{ActivityPub::Object.count(attributed_to_iri: actor.iri)}
          end

          it "does not change the iri" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"}.
              not_to change{ActivityPub::Object.find(attributed_to_iri: actor.iri).iri}
          end

          it "changes the published timestamp" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"}.
              to change{ActivityPub::Object.find(attributed_to_iri: actor.iri).published}
          end

          it "returns 400 if object does not exist" do
            post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=http://test.test/does-not-exist"
            expect(response.status_code).to eq(400)
          end

          it "returns 403 if attributed to another account" do
            object.assign(attributed_to: other).save
            post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&object=#{object.iri}"
            expect(response.status_code).to eq(403)
          end
        end

        it "creates a visible activity if public" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test&public=true"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).visible).to be_true
        end

        it "creates a visible object if public" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test&public=true"
          expect(ActivityPub::Object.find(attributed_to_iri: actor.iri).visible).to be_true
        end

        it "includes the IRI of the replied to object" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&in-reply-to=#{URI.encode_www_form(topic.iri)}"
          expect(ActivityPub::Object.find(attributed_to_iri: actor.iri).in_reply_to_iri).to eq(topic.iri)
        end

        it "returns 400 if the replied to object does not exist" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&in-reply-to=https%3A%2F%2Fremote%2Fpost"
          expect(response.status_code).to eq(400)
        end

        it "addresses (to) the specified actor" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&to=#{URI.encode_www_form(other.iri)}"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).to).to contain(other.iri)
        end

        it "addresses (cc) the specified actor" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=test&cc=#{URI.encode_www_form(other.iri)}"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).cc).to contain(other.iri)
        end

        it "addresses the public collection" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test&public=true"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).to).to contain("https://www.w3.org/ns/activitystreams#Public")
        end

        it "addresses the actor's followers collection" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test"
          expect(ActivityPub::Activity.find(actor_iri: actor.iri).cc).to contain(actor.followers)
        end

        it "enhances the content" do
          post "/actors/#{actor.username}/outbox", headers, "type=Create&content=<div>this+is+a+test</div>"
          expect(ActivityPub::Object.all.last.content).to eq("<p>this is a test</p>")
        end

        it "enhances the content" do
          post "/actors/#{actor.username}/outbox", headers, %q|type=Create&content=<figure data-trix-content-type="1"><img src="2"></figure>|
          expect(ActivityPub::Object.all.last.attachments).to eq([ActivityPub::Object::Attachment.new("2", "1")])
        end

        it "puts the activity in the actor's outbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test"}.
            to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
        end

        it "puts the activity in the other's inbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Create&content=this+is+a+test"}.
            to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
        end
      end

      context "on follow" do
        let(object) do
          ActivityPub::Actor.new(
            iri: "https://remote/actors/foo_bar",
            inbox: "https://remote/actors/foo_bar/inbox"
          ).save
        end

        it "returns 400 if object does not exist" do
          post "/actors/#{actor.username}/outbox", headers, "type=Follow&object=https://remote/actors/blah_blah"
          expect(response.status_code).to eq(400)
        end

        it "redirects when successful" do
          post "/actors/#{actor.username}/outbox", headers, "type=Follow&object=#{object.iri}"
          expect(response.status_code).to eq(302)
        end

        it "creates an unconfirmed follow relationship" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Follow&object=#{object.iri}"}.
            to change{Relationship::Social::Follow.where(from_iri: actor.iri, to_iri: object.iri, confirmed: false).size}.by(1)
        end

        it "creates a follow activity" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Follow&object=#{object.iri}"}.
            to change{ActivityPub::Activity::Follow.count(actor_iri: actor.iri, object_iri: object.iri)}.by(1)
        end

        it "puts the activity in the actor's outbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Follow&object=#{object.iri}"}.
            to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
        end

        it "sends the activity to the object's outbox" do
          post "/actors/#{actor.username}/outbox", headers, "type=Follow&object=#{object.iri}"
          expect(HTTP::Client.last?).to match("POST #{object.inbox}")
        end
      end

      context "on accept" do
        let!(relationship) do
          Relationship::Social::Follow.new(
            actor: other,
            object: actor,
            confirmed: false
          ).save
        end
        let!(follow) do
          ActivityPub::Activity::Follow.new(
            iri: "https://test.test/activities/follow",
            actor: other,
            object: actor
          ).save
        end

        it "returns 400 if a follow activity does not exist" do
          post "/actors/#{actor.username}/outbox", headers, "type=Accept&object=https://remote/activities/follow"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if the follow activity does not belong to the actor" do
          follow.assign(object: other).save
          post "/actors/#{actor.username}/outbox", headers, "type=Accept&object=#{follow.iri}"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if the relationship does not exist" do
          relationship.destroy
          post "/actors/#{actor.username}/outbox", headers, "type=Accept&object=#{follow.iri}"
          expect(response.status_code).to eq(400)
        end

        it "confirms the follow relationship" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Accept&object=#{follow.iri}"}.
            to change{Relationship.find(relationship.id).confirmed}
        end

        it "creates an accept activity" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Accept&object=#{follow.iri}"}.
            to change{ActivityPub::Activity::Accept.count(actor_iri: actor.iri, object_iri: follow.iri)}.by(1)
        end

        it "puts the activity in the actor's outbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Accept&object=#{follow.iri}"}.
            to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
        end

        it "puts the activity in the other's inbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Accept&object=#{follow.iri}"}.
            to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
        end
      end

      context "on reject" do
        let!(relationship) do
          Relationship::Social::Follow.new(
            actor: other,
            object: actor,
            confirmed: true
          ).save
        end
        let!(follow) do
          ActivityPub::Activity::Follow.new(
            iri: "https://test.test/activities/follow",
            actor: other,
            object: actor
          ).save
        end

        it "returns 400 if a follow activity does not exist" do
          post "/actors/#{actor.username}/outbox", headers, "type=Reject&object=https://remote/activities/follow"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if the follow activity does not belong to the actor" do
          follow.assign(object: other).save
          post "/actors/#{actor.username}/outbox", headers, "type=Reject&object=#{follow.iri}"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if the relationship does not exist" do
          relationship.destroy
          post "/actors/#{actor.username}/outbox", headers, "type=Reject&object=#{follow.iri}"
          expect(response.status_code).to eq(400)
        end

        it "confirms the follow relationship" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Reject&object=#{follow.iri}"}.
            to change{Relationship.find(relationship.id).confirmed}
        end

        it "creates a reject activity" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Reject&object=#{follow.iri}"}.
            to change{ActivityPub::Activity::Reject.count(actor_iri: actor.iri, object_iri: follow.iri)}.by(1)
        end

        it "puts the activity in the actor's outbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Reject&object=#{follow.iri}"}.
            to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
        end

        it "puts the activity in the other's inbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Reject&object=#{follow.iri}"}.
            to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
        end
      end

      context "when undoing an announce" do
        let!(announce) do
          ActivityPub::Activity::Announce.new(
            iri: "https://test.test/activities/announce",
            actor: actor,
            object: ActivityPub::Object.new(
              iri: "https://test.test/objects/announce",
              attributed_to: other
            )
          ).save
        end

        before_each do
          actor.assign(followers: "#{actor.iri}/followers").save
        end

        it "returns 400 if the announce activity does not exist" do
          announce.destroy
          post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(announce.iri)}"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if the announce activity does not belong to the actor" do
          announce.assign(actor: other).save
          post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(announce.iri)}"
          expect(response.status_code).to eq(400)
        end

        it "addresses (cc) the actor's followers collection" do
          post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(announce.iri)}"
          expect(ActivityPub::Activity::Undo.find(actor_iri: actor.iri).cc).to contain(actor.followers)
        end

        it "puts the activity in the actor's outbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(announce.iri)}"}.
            to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
        end

        it "puts the activity in the other's inbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(announce.iri)}"}.
            to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
        end
      end

      context "when undoing a like" do
        let!(like) do
          ActivityPub::Activity::Like.new(
            iri: "https://test.test/activities/like",
            actor: actor,
            object: ActivityPub::Object.new(
              iri: "https://test.test/objects/likw",
              attributed_to: other
            )
          ).save
        end

        before_each do
          actor.assign(followers: "#{actor.iri}/followers").save
        end

        it "returns 400 if the like activity does not exist" do
          like.destroy
          post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(like.iri)}"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if the like activity does not belong to the actor" do
          like.assign(actor: other).save
          post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(like.iri)}"
          expect(response.status_code).to eq(400)
        end

        it "addresses (cc) the actor's followers collection" do
          post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(like.iri)}"
          expect(ActivityPub::Activity::Undo.find(actor_iri: actor.iri).cc).to contain(actor.followers)
        end

        it "puts the activity in the actor's outbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(like.iri)}"}.
            to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
        end

        it "puts the activity in the other's inbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=#{URI.encode_www_form(like.iri)}"}.
            to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
        end
      end

      context "when undoing a follow" do
        let!(relationship) do
          Relationship::Social::Follow.new(
            actor: actor,
            object: other
          ).save
        end
        let!(follow) do
          ActivityPub::Activity::Follow.new(
            iri: "https://test.test/activities/follow",
            actor: actor,
            object: other
          ).save
        end

        it "returns 400 if the follow activity does not exist" do
          post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=https://remote/activities/follow"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if the follow activity does not belong to the actor" do
          follow.assign(actor: other).save
          post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=https://test.test/activities/follow"
          expect(response.status_code).to eq(400)
        end

        it "returns 400 if the relationship does not exist" do
          relationship.destroy
          post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=https://test.test/activities/follow"
          expect(response.status_code).to eq(400)
        end

        it "destroys the relationship" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=https://test.test/activities/follow"}.
            to change{Relationship::Social::Follow.count(from_iri: actor.iri, to_iri: other.iri)}.by(-1)
        end

        it "puts the activity in the actor's outbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=https://test.test/activities/follow"}.
            to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
        end

        it "puts the activity in the other's inbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Undo&object=https://test.test/activities/follow"}.
            to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
        end
      end

      context "on delete" do
        context "given an object" do
          let!(object) do
            ActivityPub::Object.new(
              iri: "https://test.test/objects/#{random_string}",
              attributed_to: actor,
              to: [other.iri]
            ).save
          end

          it "returns 400 if the object does not exist" do
            post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=https://test.test/object"
            expect(response.status_code).to eq(400)
          end

          it "returns 400 if the object is not local" do
            object.assign(iri: "https://remote/object").save
            post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{object.iri}"
            expect(response.status_code).to eq(400)
          end

          it "returns 400 if the object was not attributed to the actor" do
            object.assign(attributed_to: other).save
            post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{object.iri}"
            expect(response.status_code).to eq(400)
          end

          it "redirects when successful" do
            post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{object.iri}"
            expect(response.status_code).to eq(302)
          end

          it "redirects to the actor's home page" do
            post "/actors/#{actor.username}/outbox", headers.merge!({"Referer" => "https://test.test/remote/objects/#{object.id}"}), "type=Delete&object=#{object.iri}"
            expect(response.headers["Location"]).to eq("/actors/#{actor.username}")
          end

          it "redirects back" do
            post "/actors/#{actor.username}/outbox", headers.merge!({"Referer" => "https://test.test/the/previous/page"}), "type=Delete&object=#{object.iri}"
            expect(response.headers["Location"]).to eq("https://test.test/the/previous/page")
          end

          it "deletes the object" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{object.iri}"}.
              to change{ActivityPub::Object.count(iri: object.iri)}.by(-1)
          end

          it "puts the activity in the actor's outbox" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{object.iri}"}.
              to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
          end

          it "puts the activity in the other's inbox" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{object.iri}"}.
              to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
          end
        end

        context "given an actor" do
          before_each do
            actor.assign(followers: "#{actor.iri}/followers").save
            Relationship::Social::Follow.new(
              actor: other,
              object: actor
            ).save
          end

          it "returns 400 if the actor does not exist" do
            post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=https://test.test/actor"
            expect(response.status_code).to eq(400)
          end

          it "returns 400 if the actor is not local" do
            actor.assign(iri: "https://remote/save").save
            post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{actor.iri}"
            expect(response.status_code).to eq(400)
          end

          it "returns 400 if the actor is not the actor" do
            post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{other.iri}"
            expect(response.status_code).to eq(400)
          end

          it "deletes the actor" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{actor.iri}"}.
              to change{ActivityPub::Actor.count(iri: actor.iri)}.by(-1)
          end

          it "puts the activity in the actor's outbox" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{actor.iri}"}.
              to change{Relationship::Content::Outbox.count(from_iri: actor.iri)}.by(1)
          end

          it "puts the activity in the other's inbox" do
            expect{post "/actors/#{actor.username}/outbox", headers, "type=Delete&object=#{actor.iri}"}.
              to change{Relationship::Content::Inbox.count(from_iri: other.iri)}.by(1)
          end
        end
      end

      context "given a remote object" do
        let(object) do
          ActivityPub::Actor.new(
            iri: "https://remote/actors/foo_bar",
            inbox: "https://remote/actors/foo_bar/inbox"
          ).save
        end

        it "sends the activity to the object's inbox" do
          post "/actors/#{actor.username}/outbox", headers, "type=Follow&object=#{object.iri}"
          expect(HTTP::Client.last?).to match("POST #{object.inbox}")
        end
      end

      context "given a local object" do
        let(object) do
          username = random_string
          ActivityPub::Actor.new(
            iri: "https://test.test/actors/#{username}",
            inbox: "https://test.test/actors/#{username}/inbox"
          ).save
        end

        it "puts the activity in the object's inbox" do
          expect{post "/actors/#{actor.username}/outbox", headers, "type=Follow&object=#{object.iri}"}.
            to change{Relationship::Content::Inbox.count(from_iri: object.iri)}.by(1)
        end
      end
    end
  end
end
