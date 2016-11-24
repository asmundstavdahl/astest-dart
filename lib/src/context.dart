library astest.bdd.context;

class Context {
  Map<String, dynamic> values = new Map<String, dynamic>();

  noSuchMethod(Invocation invocation) {
    String method = invocation.memberName.toString().split("\"")[1];

    if (invocation.isGetter) {
      if (values.containsKey(method)) {
        return values[method];
      } else {
        throw new Exception(
            "Context does not have a value for '${method.toString()}'");
      }
    }

    if (invocation.isSetter) {
      return values[method.replaceAll("=", "")] =
          invocation.positionalArguments[0];
    }
  }
}
