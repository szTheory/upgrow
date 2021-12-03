---
tags: guide
layout: page
title: Software Design Principles
date: 2021-02-04
---

The list of code smells commonly found in Rails apps could go on and on. Despite how extensive that list is, the code smells are symptoms of just a few underlying problems in software design. There are principles of good software design that are often ignored in Rails apps, leading to this variety of smells. Understanding and using these principles is crucial to make good technical decisions that lead to a sustainable software architecture.

## Small Objects

As an object oriented language, Ruby is designed and optimized for execution flows consisting of message exchange between a neighborhood of objects that collaborate between themselves. And a successful object oriented flow requires multiple, specialized small objects exchanging messages between them.

There is a cost associated with breaking down the overall app logic into smaller objects. It requires the developer to reflect about the different, fine-grained concepts, goals, and responsibilities involved in the main operations of their apps. Another cost is the extra message roundrips between these small objects, since smaller objects can do less by themselves, constantly requiring other objects’ inputs and outputs. This is known as indirection: a complex operation that could be done by a single, long method in a big object is instead performed indirectly by smaller objects that collaborate to get the job done.

Small collaborative objects are better than big objects with long methods, or big objects that send multiple messages to themselves. That’s because when complex operations are broken into multiple, simpler routines, these concepts are decoupled and allow introduction of changes much faster and easier. In big objects, one must read and understand the entire body of the operation. In sets of small collaborative objects, on the other hand, it is possible to know everything that is needed for changes just by observing the exchange of messages between the objects. By encapsulating concepts and responsibilities in smaller objects, the internals of those subsystems can be altered freely without having to modify the rest of the system. Smaller objects are also much easier to test, and these tests much easier to change as well when modifications in behaviour are required.

Across Rails codebases, however, big objects usually prevail: from long controllers to big models, developers add more and more code to existing classes and rarely pause to refactor these into smaller objects.

## Single Responsibility

Objects should encapsulate no more than one responsibility. The reason different objects exist in an app is because there are multiple concepts and responsibilities to be delegated in order to properly execute extensive operations. Distributing these among objects means to assign one specific task for each of them.

Objects with a single responsibility have a discrete public interface, with just a couple of messages they are able to respond to, all of them clearly related to the one responsibility that object has. Objects that respect this principle are also easy to reason about and understand, since the responsibility they hold is clear.

Another way to phrase this principle is that objects should have only one reason to change. Since their task is well defined and discrete, it is obvious when code needs to be modified. Developers should not have to reason for too long to questions such as “should I put this code in that class?” if objects have a clear, single responsibility.

In models, controllers, and even view helpers of most Rails apps what exist is a collection of big objects that do way too much. There is no definition about the single responsibility they hold anymore. These objects just do too much, and they are changed at any time for any reason.

It is important to note that not only big objects violate this principle. Sometimes even small objects could have an identity crisis for doing too much. That’s because a lot of the object’s behaviour is coming from its ancestor chain, which causes even objects with no direct methods to actually have an incredibly large public interface.

If having a sane codebase is desired, it is crucial for developers and teams to reflect about what single responsibility an object is intended to have. This is why it is so important to give good names to classes and objects: their names should make obvious their single responsibility.

Another equally important exercise is to document at the very top of the class file the responsibility that class has. Unfortunately code documentation is not even allowed in many teams, as the self documenting code culture still persists in some groups, while others share the belief that tests are replacement for documentation.
