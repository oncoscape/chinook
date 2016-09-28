# Chinook

Chinook is a lightweight protocol for connecting web browsers to computational servers and data sources.  Simple
4-field JSON messages are exchanged over websockets.  Chinook thus makes it easy to build rich webapps which appear to
be tighly integrated but are in fact composed from loosely coupled components.  Interactive graphical web pages are
viewed and manipulated in the browser, each specialized for a particular kind and/or view of data, making calls to
remote computational servers which provide analysis tools and data.

## Why

Chinook was developed for the Oncoscape project,  which provides web-based exploratory data analysis
for computational biology, bioinformatics, and solid tumor translational research [(see STTR)](http://www.sttrcancer.org).  
The methods presented here can easily be applied in other fields.

## Goals

We hope to create a community of developers to contribute Chinook-compatible computational services, data providers, and
interactive Javascript "widgets", any of which can be combined to address a particular research program.  Simple,
complete webapps with full source code will be offered.  All of Oncoscape source code will be available, along with
curated access to computational services and Javascript widget libraries.

## Example

Example Chinook JSON Request

```
{  
   "cmd":"getServerStatus",
   "status":"request",
   "callback":"displayServerStatus",
   "payload":""
}
```

Example Chinook JSON Response


```
{  
   "cmd":"displayServerStatus",
   "status":"success",
   "callback":"",
   "payload":{  
      "currentTime":"2015-04-01 13:29:55",
      "serverVersion":"0.99.0",
      "registeredHandlers":1
   }
}

```

## Resources

 * [Quick start for programmers (a minimal demo)](https://github.com/oncoscape/chinook/wiki/Build-and-Run-the-Simplest-Chinook-Demo)
 * [ModelMPG: a 2-tab jQuery/d3/R exploration of the mtcars dataset](https://github.com/oncoscape/chinook/wiki/Explore--a-classic-R-dataset:--mtcars)
 * The Oncoscape webapp (coming soon)
 * A directory of computational services, with inputs and outputs specified (coming soon)
 * A collection of Javascript widgets suitable for adoption (coming soon)
 * [Chinook etymology (why we chose this name)](https://github.com/oncoscape/chinook/wiki/Chinook-Etymology)
