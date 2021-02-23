---
tags: guide
layout: page
title: Extensions
date: 2021-02-07
---

The new layers presented in this document were introduced in the context of a simple, small Blog app in Rails. In the real world, however, apps are much more complex than just a set of synchronous CRUD operations. This section showcases how to organize business logic objects in other common cases and additional layers.

## Associations

In this architecture, all persistence and database concerns are encapsulated under the Repository layer. The goal of this design is to have the business logic sending singular messages to a Repository for any query or writes to the database, and receive read-only Model instances as a result. There is no lazy loading whatsoever, as all data requested is fetched at once; there is also no method chaining that would end up allowing the business logic layer to compose its own queries with artifacts such as scopes and filters either. Repositories expose public methods for every single kind of query and operation required by the business logic.

This design affects directly how associations are implemented in a Rails app. Models do not have knowledge about how to load associated objects, nor do they know how to fetch Records at all. It is up to the Repository to perform the proper query with foreign keys in the database and instantiate the Models with the proper attributes and nested structures.

To better showcase associations, let’s implement an example in the Blog app. We create Comments as Records that belong to Articles. Comments have an Article ID as an attribute, which is the foreign key to an Article. Comments can be created and deleted in the context of an Article, and these endpoints are nested in the Article’s resourceful routes:

```ruby
Rails.application.routes.draw do
 resources :articles do
   resources :comments, only: [:new, :create, :destroy]
 end
end
```

With nested resources we are ensured that all actions in Comments Controller will have an Article ID as parameter. This is used to instantiate the Comment Input so the Comment is created for the target Article in the Create Comment Action, which returns a Comment as the Result.

```ruby
class CommentInput
 include ActiveModel::Model

 attr_accessor :article_id, :author, :body

 validates :article_id, presence: true
 validates :author, presence: true
 validates :body, presence: true, length: { minimum: 10 }
end
```

```ruby
class CommentsController < ApplicationController
 def new
   @input = CommentInput.new(article_id: params[:article_id])
 end

 def create
   @input = CommentInput.new(comment_params)
   @input.article_id = params[:article_id]

   CreateCommentAction.new.perform(@input)
     .and_then do |comment|
       redirect_to(article_path(comment.article_id), notice: 'Comment was successfully created.')
     end
     .or_else do |errors|
       render :new
     end
 end

 def destroy
   DeleteCommentAction.new.perform(params[:id])
   redirect_to article_path(params[:article_id]), notice: 'Comment was successfully destroyed.'
 end

 private

 # Only allow a list of trusted parameters through.
 def comment_params
   params.require(:comment_input).permit(:author, :body)
 end
end
```

Note that neither the Comment Model nor the Comment Repository have any coupling with Article. All they handle is the Article ID as a simple numeric attribute with no extra knowledge about what it is used for.

```ruby
class Comment
 attr_reader :id, :article_id, :author, :body

 def initialize(id:, article_id:, author:, body:)
   @id = id
   @article_id = article_id
   @author = author
   @body = body
 end
end
```

```ruby
class CommentRepository
 def create(input)
   record = CommentRecord.create!(
     article_id: input.article_id, author: input.author, body: input.body
   )
   to_model(record.attributes)
 end

 def delete(id)
   record = CommentRecord.find(id)
   record.destroy!
 end

 private

 def to_model(attributes)
   Comment.new(**attributes.symbolize_keys)
 end
end
```

The usefulness of the Article ID comes when we want to render all Comments for an Article in the show page, as well as render the number of Comments each Article has in the index page. We start by defining the association in the Article Record:

```ruby
class ArticleRecord < ApplicationRecord
 self.table_name = 'articles'

 has_many :comment_records, foreign_key: :article_id, dependent: :destroy
end
```

Next we give Article Repository the ability to compose Articles with associated Comments. We want to change the .all method to return all Articles each with its own list of Comments. This method will take care of crafting an optimized query with proper joins so we avoid the N+1 problem. We also want to have the ability to fetch a particular Article loaded with Comments, but instead of changing .find, we create a new .find_with_comments method. That’s because not all Actions need to have a list of Comments all the time. For example, when we fetch the Article for the edit page the list of Comments is unnecessary.

```ruby
class ArticleRepository
 def all
   ArticleRecord.all.includes(:comment_records).map do |record|
     comments = record.comment_records.map do |comment_record|
       to_comment_model(comment_record.attributes)
     end

     to_model(record.attributes.merge(comments: comments))
   end
 end

 def create(input)
   record = ArticleRecord.create!(
     title: input.title, email: input.email, body: input.body
   )
   to_model(record.attributes)
 end

 def find(id)
   record = ArticleRecord.find(id)
   to_model(record.attributes)
 end

 def find_with_comments(id)
   record = ArticleRecord.find(id)

   comments = record.comment_records.map do |comment_record|
     to_comment_model(comment_record.attributes)
   end

   to_model(record.attributes.merge(comments: comments))
 end

 def update(id, input)
   record = ArticleRecord.find(id)
   record.update!(
     title: input.title, email: input.email, body: input.body
   )
   to_model(record.attributes)
 end

 def delete(id)
   record = ArticleRecord.find(id)
   record.destroy!
 end

 private

 def to_model(attributes)
   Article.new(**attributes.symbolize_keys)
 end

 def to_comment_model(attributes)
   Comment.new(**attributes.symbolize_keys)
 end
end
```

The Article Model must be changed in order to receive an array of Comments during initialization. As mentioned before, associations are optionally loaded by the Repository, meaning that the Model’s associations are optional attributes. It is a good practice, therefore, to ensure that only Model instances previously initialized with associations can actually respond to an association message, so we will make the Model raise an error in case someone requests a list of Comments to an Article that was not initialized with one.

```ruby
class Article
 class AssocationNotLoadedError < StandardError; end

 attr_reader :id, :title, :email, :body, :created_at, :updated_at

 def initialize(id:, title:, email:, body:, created_at:, updated_at:, comments: nil)
   @id = id
   @title = title
   @email = email
   @body = body
   @created_at = created_at
   @updated_at = updated_at
   @comments = comments
 end

 def comments
   raise AssocationNotLoadedError if @comments.nil?
   @comments
 end
end
```

The Show Article Action now can request an Article along with its Comments by sending the proper message to the Article Repository.

```ruby
class ShowArticleAction < Action
 result :article

 def perform(id)
   article = ArticleRepository.new.find_with_comments(id)

   result.success(article: article)
 end
end
```

The Controller won’t need to be changed at all, since it simply extracts the Article from the Result and forwards it to the view. The view now can render the Comments by reading the Model’s attribute.

```erb
<p id="notice"><%= notice %></p>

<p>
 <strong>Title:</strong>
 <%= @article.title %>
</p>

<p>
 <strong>Body:</strong>
 <%= @article.body %>
</p>

<%= link_to 'Edit', edit_article_path(@article.id) %> |
<%= link_to 'Back', articles_path %>

<h3>Comments</h3>

<% @article.comments.each do |comment| %>
 <p>
   <strong><%= comment.author %> says:</strong>
 </p>

 <p><%= comment.body %></p>

 <%= button_to 'Delete', article_comment_path(@article.id, comment.id), method: :delete %>
<% end %>

<%= link_to 'Create comment', new_article_comment_path(@article.id) %>


The index view can also now render the Comments count for each Article:
<p id="notice"><%= notice %></p>

<h1>Articles</h1>

<table>
 <thead>
   <tr>
     <th>Title</th>
     <th>Email</th>
     <th>Body</th>
     <th>Comments count</th>
     <th colspan="3"></th>
   </tr>
 </thead>

 <tbody>
   <% @articles.each do |article| %>
     <tr>
       <td><%= article.title %></td>
       <td><%= article.email %></td>
       <td><%= article.body %></td>
       <td><%= article.comments.count %></td>
       <td><%= link_to 'Show', article_path(article.id) %></td>
       <td><%= link_to 'Edit', edit_article_path(article.id) %></td>
       <td><%= button_to 'Destroy', article_path(article.id), method: :delete, data: { confirm: 'Are you sure?' } %></td>
     </tr>
   <% end %>
 </tbody>
</table>

<br>

<%= link_to 'New Article', new_article_path %>
```

Note that since we are just rendering the number of Comments, having all these Models loaded in each Article is actually a waste of resources. A more optimized design could be made by adding a comments count attribute in Article and setting it in the Article Repository. But the overall design principle remains the same: Repositories return immutable, read-only Model instances with the data properly mapped.

As mentioned before, associations are not required to be loaded for every single use case. For instance, when we render the edit page to update an Article: only the Article that is supposed to be edited is fetched to prefill the form, but not its Comments. That is why it is crucial to have specific Action objects handling specific requests: each Action takes care of only fetching what is necessary for each use case by sending the proper message to the Repository.

## Mailers

Rails apps often need to send emails as part of handling a request, which is done through the Action Mailer framework. Mailer classes receive data as parameters and render the body of emails to be sent using views. Therefore, Mailers should be limited to hold logic related to composing emails alone, and coupling with business logic objects such as Actions and Repositories should be avoided.

Back to the Blog example, let’s say we want to notify a user that a new Comment was posted in one of their Articles. After introducing a new email attribute in Articles, we can create a Mailer to send the email. The Mailer will be invoked when a new Comment is created in the Create Comment Action, with the data it needs already fetched: the Comment to be included in the message as well the Article that has the email address of the author.

```ruby
class NotificationMailer < ApplicationMailer
 default from: 'notifications@example.com'

 def new_comment
   @article = params[:article]
   @comment = params[:comment]
   mail(to: @article.email, subject: 'New comment in your article')
 end
end
```

```erb
Hello!

<%= @comment.author %> just posted the following comment in your article
"<%= @article.title %>":

<%= @comment.body %>
```

```ruby
class CreateCommentAction < Action
 result :comment

 def perform(input)
   if input.valid?
     comment = CommentRepository.new.create(input)
     article = ArticleRepository.new.find(comment.article_id)
     NotificationMailer.with(
       comment: comment, article: article
     ).new_comment.deliver_now

     result.success(comment: comment)
   else
     result.failure(input.errors)
   end
 end
end
```

Note that the approach above only works for synchronous email deliveries (the ones performed with deliver_now). Mailers have the ability to deliver emails through a background job, but that would require arguments to be serializable according to Active Job’s expectations, such as using Global ID. We are using Models as parameters, and those do not meet the API requirements by design. Instead, for asynchronous email deliveries with Models, we should implement our own jobs to properly retrieve the required data later in the background, and still perform email deliveries synchronously in the job queue.

## Background Jobs

Jobs are used to defer part of the business logic for later execution. They are enqueued with certain parameters that are serialized, and eventually performed in a background queue, which deserializes the parameters and calls the Job. Active Job is the Rails framework that provides the APIs for this workflow so the app can be abstracted away from the specifics of the background queue in use.

In this architecture, we identify Jobs as being part of the business logic layer of the app, integrated with the Action workflow. Jobs are simply a subset of an Action’s content that is deferred to be performed asynchronously: their arguments are already validated and part of the request processing workflow.

Another key difference between Actions and Jobs is that Jobs don’t return any values. Instead, they define retry mechanisms for eventual failures. The business logic performed by Jobs should take this into account and be designed to be idempotent and retried without unwanted side-effects.

Let’s revisit the Blog app and introduce a Job so we can perform the email delivery in the background.

```ruby
class NewCommentEmailJob < ApplicationJob
 queue_as :default

 def perform(comment_id)
   comment = CommentRepository.new.find(comment_id)
   article = ArticleRepository.new.find(comment.article_id)
   NotificationMailer.with(comment: comment, article: article)
     .new_comment.deliver_now
 end
end
```

```ruby
class CreateCommentAction < Action
 result :comment

 def perform(input)
   if input.valid?
     comment = CommentRepository.new.create(input)
     NewCommentEmailJob.perform_later(comment.id)

     result.success(comment: comment)
   else
     result.failure(input.errors)
   end
 end
end
```

A benefit of moving part of the business logic from Create Comment Action into New Comment Email Job is that it ended up reducing the coupling between the Action and other objects of the system: the Action no longer needs to call Article Repository or the Mailer. These are now part of the Job’s business logic.

## GraphQL

An increasing number of contemporary Rails apps have adopted GraphQL as their API layer. Usually these are background services for web and mobile apps, or part of a network of distributed systems. GraphQL is usually implemented by exposing a single HTTP endpoint in Rails that receive payloads that are then processed by a set of GraphQL related objects to translate this data as queries and mutations according to a previously defined schema.

The GraphQL layer of the Rails app is similar to the controller and view layers: they should be responsible only for extracting data from incoming payloads, forward them to Actions, and prepare Action Results for presentation as return values. queries and mutations should not hold any business logic. Since Actions and Results have well-defined structures, they are ideal building blocks to create clear and sustainable GraphQL APIs.

Let’s see some examples in the context of the Blog app. We can enable the creation of Articles via the GraphQL API through a mutation that receives the values as arguments and returns the proper Result fields. Since all our mutations will return a Result, they are sure to include fields such as a success boolean and an optional collection of errors. These can be defined in a mutation base class:

```ruby
# app/graphql/mutations/base_mutation.rb

module Mutations
 class BaseMutation < GraphQL::Schema::Mutation
   field_class Types::BaseField

   field :success, Boolean, null: false
   field :errors, [Types::ErrorType], null: false
 end
end
```

Note that the errors field in the mutation base is an array of errors as defined by the Error type. Each error should include a message, an error code, and an optional field to make it easier for API clients to understand them accordingly.

```ruby
# app/graphql/types/error_type.rb

module Types
 class ErrorType < BaseObject
   field :field, String, null: true
   field :code, String, null: false
   field :message, String, null: false
 end
end
```

Now we can go ahead and implement the Create Article mutation:

```ruby
# app/graphql/mutations/create_article.rb

module Mutations
 class CreateArticle < BaseMutation
   argument :title, String, required: true
   argument :email, String, required: true
   argument :body, String, required: true

   field :article, Types::ArticleType, null: true

   def resolve(title:, email:, body:)
     input = ArticleInput.new(title: title, email: email, body: body)

     CreateArticleAction.new.perform(input)
   end
 end
end
```

```ruby
# app/graphql/types/article_type.rb

module Types
 class ArticleType < BaseObject
   field :title, String, null: false
   field :email, String, null: false
   field :body, String, null: false
 end
end
```

As seen above, the mutation itself simply instantiates an Input and passes it to the proper Action. The Result that contains the created Article is then mapped to the Article GraphQL type seamlessly. In case of errors, the mutation will have an empty article field but the errors field will be populated with the proper messages and codes. All of that without ever leaking business logic into the GraphQL layer.
