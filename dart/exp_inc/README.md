# Exported functions

This directory contains files that list the functions that should be exported
by Emscripten for access from JS. The size of the Ferret module (ferret.js)
may be reduced by removing certain functions from the list. The query parser
contributes significantly to the overall size of the module.
