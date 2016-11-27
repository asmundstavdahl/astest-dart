library astest.bdd;

import "bdd/specification.dart";

Specification feature(String description) {
  var specification = new Specification(description);

  return specification;
}
Specification scenario(String description) => feature(description);
