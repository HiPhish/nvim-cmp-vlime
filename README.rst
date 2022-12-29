.. default-role:: code

###########
 cmp-vlime
###########

Completion source for `nvim-cmp`_ which uses `Vlime`_ for completion
candidates.

.. image:: https://user-images.githubusercontent.com/4954650/209943725-6b913d42-8285-48b1-b800-2301b42016cb.png
   :alt: Screenshot of Neovim showing a piece of Common Lisp code being
         completed; the completions are shown in a floating window and next to
         the completions there is a floating window showing the documentation
         for the currently selected item.


Installation
############

Install this like any other plugin. The source will be automatically registered
for use with nvim-cmp, but you still have to reference it in your
configuration. Example:
 
.. code:: lua

    require('cmp').setup.filetype({'lisp'}, {
        sources = {
            {name = 'vlime'}
        }
    })

For more information please refer to the documentation_.


License
#######

Licensed under the terms of the MIT (Expat) license.  Please refer to the
LICENSE_ file for more information.


.. ----------------------------------------------------------------------------
.. _nvim-cmp: https://github.com/hrsh7th/nvim-cmp/
.. _Vlime: https://github.com/vlime/vlime
.. _documentation: doc/cmp-vlime.txt
.. _License: LICENSE.txt
