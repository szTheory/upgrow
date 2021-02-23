---
tags: guide
layout: page
title: A Better Architecture
date: 2021-02-05
---

It is possible to design an architecture in Rails apps that allow changes to be easily introduced and the development process sustainable for the long term. The guideline for a good Rails design is to think about ways to have smaller objects with single responsibilities. These small objects should collaborate with each other by exchanging messages, while maintaining loose coupling. This is achieved by clarifying and enforcing strict tasks for the existing objects provided by Rails, as well as increasing indirection by introducing new layers of objects, also with clear responsibilities.

Let’s start by revisiting the existing object layers Rails provides by default and give them clear single responsibilities.

## Controllers
Apart from the routes, controllers are the outermost layer of a Rails app. It is where HTTP requests first arrive in the Ruby code and where the final HTTP response is returned.

Controllers should be responsible for dealing with the specifics of HTTP, making sure that everything the app needs to know from requests are properly extracted and that no intricacies of the protocol is leaked to the other layers of Ruby code. Therefore, anything HTTP-specific such as headers, query parameters, session storage, cookies, etags, and others, belong to the controller layer.

As a corollary, controllers should not contain business logic of any kind. Validations, queries, enqueueing jobs and sending emails are examples of responsibilities that do not fit into controllers, as they are not related to HTTP transformations. Controllers should simply fetch data from requests and send them to other objects, and finally receive what these objects return in order to craft the proper HTTP response.

## Views

The view layer is actually part of the controllers. Since controllers craft the HTTP response, it needs to define the response body as well. But since the body in itself can be quite complex, it is necessary to delegate this part of response crafting to a specialized resource. This is the view layer, with the view context, template files, and helpers.

Views are, therefore, responsible for properly assembling the response body. In most cases the body content is an HTML document.

In views, the resulting data from business logic layers returned to the controller are formatted for presentation. For HTML, views would append and interpolate data in tags and assign proper attributes.

Views should receive the response data already processed and ready for presentation. It is not the responsibility of the view layer to encapsulate business logic of any kind. For example, conditionals in views should be rare, limited to logic that is strictly related to presentation concerns. If presentation logic is needed, these should go in view helpers in order to avoid polluting templates with Ruby code.

## Models

There is no obvious answer about what the single responsibility of Rails models should be. That’s because by default they are already overloaded with features and capabilities. Even when models have an empty body, they are packed with multiple frameworks and mixins such as Active Record and Active Model, along their own submodules. Beyond being just a data transporting resource, the resulting object inherits a broad public interface, capable of doing validations, database persistence, transformations, callbacks, as well as wiring themselves with other models through associations.

In order to keep a sane codebase, it is crucial to select a single responsibility for these objects. The sensible choice is to assign to them the task of managing database persistence of particular sets of resources. In other words, a more thoughtful software design approach to Rails requires to strip Rails models from most of their features, and keep only what is directly related to database operations.

As discussed previously, the single responsibility of objects should be reflected in their naming. The term “model” is too vague to represent database persistence. Therefore, the classic Rails models should be renamed to “records”. They are the database layer of the codebase, using a subset of Active Record to deal with the DBMS.

Records should not have any business logic beyond code that is directly related to database persistence. Validations should not be performed in Records, as data integrity can be ensured with constraints in the database schema; certain constraints are even only effectively enforced that way, such as uniqueness of certain keys. Records should be as close as possible to the raw representation of database values in Ruby, with no additional capabilities and transformations. Needless to say that callbacks and associations should be avoided at all costs.
