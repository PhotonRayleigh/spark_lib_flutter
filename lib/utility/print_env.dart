import 'dart:io';

void print_env_vars() {
  var env = Platform.environment;
  print("Printing env vars:");
  env.forEach((key, value) {
    print("Var: $key, Val: $value");
  });
}
