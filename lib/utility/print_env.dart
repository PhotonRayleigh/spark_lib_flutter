import 'dart:io';

void printEnvVars() {
  var env = Platform.environment;
  print("Printing env vars:");
  env.forEach((key, value) {
    print("Var: $key, Val: $value");
  });
}
