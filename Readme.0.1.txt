  Edi2SGML - an approach towards XXMMLL//EEDDII as a prototype in perl
  release 0.1 - about the beauty of plain text
  Michael Koehne, kkrraaeehhee@@bbaakkuunniinn..nnoorrtthh..ddee
  v0.1, Thu Dec 10 05:49:59  1998

  Edi2SGML is a set of perl scripts, hopefully becoming a module, that
  is translating EDIFACT into SGML. This 0.1 version neither contains a
  document type definition for the produced SGML, nor does it contain a
  SGML parser to translate its documents back to EDI. Its intended as a
  working horse, and I hope that some diesel or expat, will be able to
  translate my Edi2SGML to XML/EDI and vice versa, once we have a stan-
  dard.
  ______________________________________________________________________

  Table of Contents:

  1.      Introduction

  2.      About the beauty of plain text

  3.      Roadmap

  4.      Download
  ______________________________________________________________________

  11..  IInnttrroodduuccttiioonn

  EEDDIIFFAACCTT often called " nightmare of paper less office " once you show
  a programmer the standard draft. Those 2700 pages of horror full
  advisory board English has cursed many programmers with headaches.

  EDIFACT is trying the impossible: a single form for the real world.

  Orders, invoices, fright papers, ..., always look different, if they
  come from different companies. EDIFACT tries to fulfill all needs of
  commercial messages regardless of branch and origin. Of course those
  99% real world is neither simple nor complete.  Nevertheless its
  important for the top companies and their suppliers, you know those
  who can pay a mainframe and a pack of gurus, and in use since 1995.

  XXMMLL//EEDDII is trying to provide a simpler (KISS) format that can be
  translated from and into EDI, to allow smaller companies to avoid
  slaughtering forests and retyping stupid lines into a computer
  keyboard printed by other computers.

  This is NNOOTT XML/EDI, its certainly not KISS. I would prefer a
  <<iissbbnn//11556655992211887799// for PPIIAA++55++11556655992211887799::IIBB, but not

       <additional.product.id>
         <product.id.function.qualifier coded="5"/Product identification/
         <item.number.identification>
           <item.number/1565921879/
           <item.number.type coded="IB"/ISBN (International Standard Book Number)/
         </item.number.identification>
       </additional.product.id>

  22..  AAbboouutt tthhee bbeeaauuttyy ooff ppllaaiinn tteexxtt

  Standards should be based on standards. EDIFACT is based on ASCII and
  documentation is available from Premenos as plain text. Well they
  contain some funny characters. I took the freedom, to replace them
  with ASCII in this distribution to improve readability. I don't talk
  about human readability here. A friend at SAP joked that plain paper
  is the only platform independent format in that case. But I disliked
  to retype them. And plain text is more flexible, as I'm a programmer.

  I've included those modified documents, so others can be able to
  rebuild the tables also included in this distribution. You may need a
  Unix like system because of newline conventions. This current 0.1
  version is not intended to become "installed", just run everything
  from this path.

               % perl bin/create_codes.pl
               % perl bin/create_composite.pl
               % perl bin/create_segment.pl
               % perl bin/edi2sgml.pl examples/nad_buyer.edi

  You can try other example files, and I really want to read how your
  EDI messages look like. Think about the OO''RReeiillllyy invoice or the
  DDuubbbbeell::TTeesstt and you should catch the clue. I've tried to implement the
  UUNNAA right, but this may need some additional debugging. Take a look at
  the difference between the edi.tst files from Frankfurt and the
  Springer message. The last one is using newline as a 9th character in
  UNA, so its nearly human readable.

  33..  RRooaaddmmaapp

  I plan to use even and odd numbering, so a 0.2 version will be more
  debugged, better documented and more looking like a module, while the
  0.3 will contain the next features.

  I plan to add SDBM for faster access on the tables, and some other
  minor improvement. The next important step will be a reverse
  engineering of the document type definition of the original EDI
  standard draft. And of course a DTD for my Edi2SGML also, after I have
  looked at those _d.96b files more closely.

  44..  DDoowwnnllooaadd

  I just got a message from PAUSE that I can upload it to :

               $CPAN/authors/id/K/KR/KRAEHE

  You may also get it from my homepage. Try something like:

               http://human.is-bremen.de/~kraehe/pub/Edi2SGML.?.?.tgz

  Be warned its a bit over a megabyte, as it includes the Premenos files
  also. The main script is only about 300 lines, so ffiirrsstt ddoonntt ppaanniikk.

