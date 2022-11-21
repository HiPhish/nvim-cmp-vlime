.. default-role:: code


#############################
 Hacking on the Vlime source
#############################


Vlime results
#############

The following are my findings on how Vlime delivers its results to the editor;
none of this is documented, so it might change in the future.

Taking a sample
===============

First we need to get hold of the results by manually triggering completion.
Start a Vlime server and execute the following Vim script code:

.. code:: vim

   let g:completions = []

   " Completion is asynchronous, so we need this callback for its side effect
   function OnComplete(connection, result)
      let g:completions = a:result
   endfunction

   " Run this after connecting to Swank
   let g:connection = vlime#connection#Get(v:true)

   " Complete the string 'defu'
   call vlime#connection#Get(v:true).FuzzyCompletions('defu', function('OnComplete'))
   call vlime#connection#Get(v:true).SimpleCompletions('defu', function('OnComplete'))

We can now inspect the variable `g:completions`.


Result
======

Here is the fuzzy result, in JSON notation for better readability.

.. code:: json

   [
      [
         ["defun", "44.35", [[0, "defu"]], "-f---m--"],
         ["defconstant-uneql", "38.10", [[0, "def"], [12, "u"]], "---ct---"],
         ["defconstant-uneql-name", "37.91", [[0, "def"], [12, "u"]], "-f------"],
         ["defconstant-uneql-new-value", "37.80", [[0, "def"], [12, "u"]], "-f------"],
         ["defconstant-uneql-old-value", "37.80", [[0, "def"], [12, "u"]], "-f------"],
         ["*derive-function-types*", "36.20", [[1, "de"], [8, "fu"]], "b-------"],
         ["defstruct", "32.05", [[0, "def"], [6, "u"]], "-f---m--"],
         ["default-init-file", "31.10", [[0, "def"], [4, "u"]], "--------"],
         ["define-alien-routine", "30.97", [[0, "def"], [15, "u"]], "-f---m--"],
         ["define-source-context", "30.94", [[0, "def"], [9, "u"]], "-f---m--"],
         ["*default-external-format*", "30.84", [[1, "def"], [5, "u"]], "b-------"],
         ["*default-pathname-defaults*", "30.80", [[1, "def"], [5, "u"]], "b-------"],
         ["*default-c-string-external-format*", "30.71", [[1, "def"], [5, "u"]], "b-------"],
         ["*trace-report-default*", "25.77", [[14, "def"], [18, "u"]], "b-------"],
         ["*block-compile-default*", "25.74", [[15, "def"], [19, "u"]], "b-------"],
         ["*read-default-float-format*", "25.66", [[6, "def"], [10, "u"]], "b-------"],
         ["*trace-encapsulate-default*", "25.66", [[19, "def"], [23, "u"]], "b-------"],
         ["undefined-function", "19.72", [[2, "de"], [10, "fu"]], "---ct---"],
         ["*module-provider-functions*", "19.47", [[13, "de"], [17, "fu"]], "b-------"],
         ["standard-generic-function", "18.45", [[4, "d"], [10, "e"], [17, "fu"]], "---ct---"]
      ],
      null
   ]

Here is the simple result for `make-a`:

.. code:: json 

   [
      [
         "make-alien",
         "make-alien-string",
         "make-array"
      ],
      "make-a"
   ]

Analysis
========

Simple completion
-----------------

The result is a list `[items, something]` of two elements. The first element is
a list of literal completion candidates.

Fuzzy completion
----------------

The result is a list `[items, something]` of two elements. I don't know what
the second element is. The first element is a list of completion candidates.
Each candidate has four items:

#) The text of the completion candidate
#) The score how good the match was
#) A list of matches
#) Flags of the type of symbol, i.e. whether it is a function, a macro, a type,
   etc.

The matches describe where each part of the argument matches the symbol name.
Each match is a list `[position, substring]`, where `position` is the 0-based
index of the first character and `substring` is the substring of the argument
which matches.

The flags are one of the following: `bfgctmsp`

====  =================
Flag  Meaning
====  =================
`b`   `boundp`
`f`   `fboundp`
`g`   Generic function
`c`   Class
`t`   Type
`m`   Macro
`s`   special operator
`p`   Package
====  =================
