.ui.fluid.actor.card
  - if actor.blocked?
    .blocked.content
      em This actor is blocked!
  - else
    - image = actor.image.presence
    - style = image ? "background-image: url(#{actor.image});" : nil
    .content class=(!image ? "placeholder" : nil) style=style
      - if actor.icon.presence
        img src=actor.icon
      - else
        i.user.icon
    - if (summary = actor.summary)
      .extra.content
        p == s summary
  .extra.content
    a.left.floated href=actor.iri
      .meta= actor.display_name
      .meta= actor.account_uri
    - if (_account = env.account?) && _account.actor != actor
      - if env.request.path =~ /followers$/ && actor.follows?(_account.actor, confirmed: false) && (_follow = ActivityPub::Activity::Follow.follows?(actor, _account.actor))
        == form_button "Block", block_actor_path(actor), form_class: "ui form right floated", button_class: "ui button dangerous", button_data: {"modal": "block.actor"}
        == activity_button "Reject", outbox_path(_account), _follow.iri, form_class: "ui form right floated", button_class: "ui button reject"
        == activity_button "Accept", outbox_path(_account), _follow.iri, form_class: "ui form right floated", button_class: "ui button accept"
      - elsif (_follow = ActivityPub::Activity::Follow.follows?(_account.actor, actor))
        == activity_button "Unfollow", outbox_path(_account), _follow.iri, type: "Undo", form_class: "ui form right floated"
      - else
        == form_button "Block", block_actor_path(actor), form_class: "ui form right floated", button_class: "ui button dangerous", button_data: {"modal": "block.actor"}
        == activity_button "Follow", outbox_path(_account), actor.iri, form_class: "ui form right floated", button_class: "ui button primary"
    - elsif !_account && actor.local?
      == form_button "Follow", actor_remote_follow_path(actor), method: "GET", form_class: "ui form right floated", button_class: "ui button primary"
