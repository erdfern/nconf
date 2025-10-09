{ lib
, writeShellApplication
}:
writeShellApplication {
  name = "obelisk";
  checkPhase = "";
  # runtimeInputs = [adb];
  text =
    let
      # coordinates, assuming 850x960
      bottomRowY = 1300;

      storeX = 740;
      menuX = 740;

      tap = x: y: "adb shell input swipe ${x} ${y} ${x} ${y} 100";

      tapBottom = x: tap x bottomRowY;

      tapStore = tapBottom storeX;
      tapMenu = tapBottom menuX;

      delay = 1;
    in
    ''
      # input
      SWIPE_DELAY="100"

      while true
      do
        echo ${tapMenu}

        sleep "${delay}"
      done
    '';
}
