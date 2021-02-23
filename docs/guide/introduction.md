---
tags: guide
layout: page
title: Introduction
date: 2021-02-01
---

Ruby on Rails is the framework of choice for web apps at Shopify. It is an
opinionated stack for quick and easy development of apps that need standard
persistence with relational databases, an HTTP server, and HTML views.

By design, Rails does not define conventions for structuring business logic and
domain-specific code, leaving developers to define their own architecture and
best practices for a sustainable codebase.

In fast product development teams, budgets and deadlines interfere with this
architectural work, leading to poorly written business logic and complicated
code that is very hard to maintain long term. Even when developer teams take
the time to think about what a good architecture in Rails look like, this work
is likely required to be done all over again when a new Rails app needs to be
created.

This project aims to make it easier for both new and existing Rails apps to
adopt patterns that are proven to make code more sustainable long term, and
codebases easier to maintain and extend. We will recommend a set of abstractions
and practices that are simple, yet powerful in organizing code in Rails apps in
a way that allows fast-growing apps to remain easy to change.
