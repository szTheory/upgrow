---
tags: guide
layout: page
title: Final Words
date: 2021-02-09
---

Ruby on Rails has reshaped the world of web frameworks by empowering developers to ship apps incredibly fast. Through well designed features, conventions, and the clever use of the strengths of the Ruby language, Rails offers a quick and easy starting point for the creation of feature-rich apps.

When thinking about long-term, sustainable development, however, one must weigh the basic architecture offered by Rails and consider ways to redesign it so changes can be introduced without much hassle.

Granted, not all Rails apps require this thoughtful design exercise. It all comes down to the business strategies and scenarios where the technology is inserted into. For experiments, companies, and teams looking for short-term solutions, or small cases in which growth is not expected, the simple Rails default architecture might be the perfect fit.

More often than not, though, developers use Ruby on Rails in fast growing companies with ambitious business goals, targeting expanding existing features, adding new ones, quickly addressing bugs in production, and hiring more and more engineers to work on the same codebase. For such teams, the importance of being able to change code quickly cannot be overstated. Companies that can ship changes fast are the ones who innovate, grow, and make a difference in the world; companies that are not able to change fast end up lagging behind, lose market share, and ultimately die.

The architecture defined in this document is a more robust starting point for such teams and companies. It offers a more robust starting point for Rails apps, which initially will need to invest more in indirection and overall more code volume. This design investment pays off once the app is in production and used by people, by allowing developers to evolve it sustainably.

It is important to mention that this architecture won’t give all the answers for all cases, and it doesn’t even attempt to. Ultimately the responsibility to maintain a good design still relies on the team that owns the codebase, and constant evaluation of business plans aligned with principles of good software design is required at all times.
