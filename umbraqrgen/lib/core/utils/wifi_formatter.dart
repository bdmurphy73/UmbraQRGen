class WifiFormatter {
  WifiFormatter._();

  static String format(String ssid, String password) {
    return 'WIFI:T:WPA;S:$ssid;P:$password;;';
  }
}
