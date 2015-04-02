# Chinook

 * [quick start for programmers](https://github.com/oncoscape/chinook/wiki)

Chinook is a  protocol for exchanging simple, 4-field JSON messages over websockets,
passing back and forth between Javascript in the browser, and computational servers 
(typically written in R and Python).  Chinook thus facilitates
the construction of loosely-coupled, highly interactive webapps.
Our main focus lies in computational biology, bioinformatics, and solid tumor translational
research [(see STTR)](http://www.sttrcancer.org).  The methods presented here, however,
can easily be applied in other fields.

Our protocol gets its name from the [Chinook
Jargon](http://en.wikipedia.org/wiki/Chinook_Jargon), a very simple
trading language - a pidgin or contact language - used in the Pacific
Northwest for many centuries.  Some report Chinook was spoken in Seattle as
recently as the 1930's.   As a project based in Seattle at the Fred Hutchinson
Cancer Research Center, close by the Salish Sea, and with native influence
visible throughout the city, this association with indigenous native peoples
has particular resonance. 

Chinook had a vocabulary of about 400 words, and a very simple
grammar.  It provided a common jargon, a shared "little language",
allowing speakers of many different (and sometimes quite unrelated)
Amerindian languages to conduct extensive trade with each other.  A
few French and English words were added in the nineteenth century.

Chinook is a model and inspiration for us because we face a similar
situation: like Chinook speakers, we need to connect rich and complex
entities as simply as possible.  Economies were connected in the
historical case.  In our case, we wish to connect problem domains
(genomic analysis, network biology, clinical histories), together with
computational biology and visualization tools, creating user-friendly
exploratory webapps.  Chinook speakers developed a broad and extensive
collaborative economy, connecting distinct cultures, using only a
small number of shared words. Similarly, we seek to create an
extensive computational environment based upon the exchange of simple
messages between powerful computational services and visualization
tools.

# Putting the Chinook Protocol to Work: Loosely Coupled Computational Services and Browser Visualizations
#### A Common Situation (excellent tools, unconnected,  not available to the non-expert programmer)
![Uncoupled](/images/legoBlocksUnconnected.png)

#### Oncoscape (using the Chinook Protocol)
![Coupled](/images/legoBlocksConnected.png)
