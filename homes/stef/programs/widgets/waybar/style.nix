{
    config,
    lib,
    ...
}:
let
    colours = config.stylix.base16Scheme;
    betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
in
with lib;
{
    # Configure & Theme Waybar
    programs.waybar = {
        style = concatStrings [
            ''
                /* >>> ALL MODULES <<< */

                * {
                    font-size: 14px;
                    font-family: FiraCodeNerdFont, MapleMono, JetBrainsMono NFM, Font Awesome, sans-serif;
                    font-weight: bold;
                    color: #1e1e2e;
                }

                window#waybar {
                    background-color: rgba(0, 0, 0, 0);
                }

                tooltip {
                    background: #1e1e2e;
                    border-radius: 15px;
                }

                tooltip label {
                    color: #cdd6f4;
                }


                /* Stuff that needs to be rounded left. */

                #cpu,
                #idle_inhibitor,
                #network {
                    border-radius: 15px 0px 0px 15px;
                    margin: 3px 0px 3px 2px;
                    padding: 3px 5px 3px 15px;
                }


                /* Stuff that needs to be rounded right. */

                #memory,
                #pulseaudio,
                #custom-notification {
                    border-radius: 0px 15px 15px 0px;
                    margin: 3px 2px 3px 0px;
                    padding: 3px 10px 3px 5px;
                } 


                /* Stuff that's rounded both left and right, i.e. standalone pills. */

                #clock,
                #image,
                #battery,
                #custom-song,
                #custom-lyrics {
                    border-radius: 15px;
                    margin: 3px 4px;
                    padding: 3px 10px;
                } 


                /* Stuff that aren't rounded in either direction, i.e. sandwiched pills. */

                #disk {
                    border-radius: 0px;
                    margin: 3px 0px;
                    padding: 3px 14px;
                } 



                /* >>> LEFT MODULES <<< */

                #cpu,
                #disk,
                #memory {
                    background: #f38ba8;
                }

                #battery {
                    background: #fab387;
                }

                #clock {
                    background: #f9e2af;
                }



                /* >>> CENTER MODULES <<< */

                #image {
                    padding: 0;
                }

                #custom-song {
                    background: #a6e3a1;
                }

                #custom-lyrics {
                    background: #89dceb;
                }



                /* >>> RIGHT MODULES <<< */

                #idle_inhibitor,
                #pulseaudio {
                    background: #74c7ec;
                }

                #network,
                #custom-notification {
                    background: #cba6f7;
                }

                /* SONG PERCENTAGE */

                #custom-song.perc0-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 0.0%,
                    #77b872 0.1%
                    );
                }

                #custom-song.perc1-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 1.0%,
                    #77b872 1.1%
                    );
                }

                #custom-song.perc2-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 2.0%,
                    #77b872 2.1%
                    );
                }

                #custom-song.perc3-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 3.0%,
                    #77b872 3.1%
                    );
                }

                #custom-song.perc4-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 4.0%,
                    #77b872 4.1%
                    );
                }

                #custom-song.perc5-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 5.0%,
                    #77b872 5.1%
                    );
                }

                #custom-song.perc6-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 6.0%,
                    #77b872 6.1%
                    );
                }

                #custom-song.perc7-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 7.0%,
                    #77b872 7.1%
                    );
                }

                #custom-song.perc8-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 8.0%,
                    #77b872 8.1%
                    );
                }

                #custom-song.perc9-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 9.0%,
                    #77b872 9.1%
                    );
                }

                #custom-song.perc10-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 10.0%,
                    #77b872 10.1%
                    );
                }

                #custom-song.perc11-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 11.0%,
                    #77b872 11.1%
                    );
                }

                #custom-song.perc12-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 12.0%,
                    #77b872 12.1%
                    );
                }

                #custom-song.perc13-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 13.0%,
                    #77b872 13.1%
                    );
                }

                #custom-song.perc14-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 14.0%,
                    #77b872 14.1%
                    );
                }

                #custom-song.perc15-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 15.0%,
                    #77b872 15.1%
                    );
                }

                #custom-song.perc16-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 16.0%,
                    #77b872 16.1%
                    );
                }

                #custom-song.perc17-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 17.0%,
                    #77b872 17.1%
                    );
                }

                #custom-song.perc18-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 18.0%,
                    #77b872 18.1%
                    );
                }

                #custom-song.perc19-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 19.0%,
                    #77b872 19.1%
                    );
                }

                #custom-song.perc20-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 20.0%,
                    #77b872 20.1%
                    );
                }

                #custom-song.perc21-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 21.0%,
                    #77b872 21.1%
                    );
                }

                #custom-song.perc22-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 22.0%,
                    #77b872 22.1%
                    );
                }

                #custom-song.perc23-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 23.0%,
                    #77b872 23.1%
                    );
                }

                #custom-song.perc24-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 24.0%,
                    #77b872 24.1%
                    );
                }

                #custom-song.perc25-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 25.0%,
                    #77b872 25.1%
                    );
                }

                #custom-song.perc26-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 26.0%,
                    #77b872 26.1%
                    );
                }

                #custom-song.perc27-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 27.0%,
                    #77b872 27.1%
                    );
                }

                #custom-song.perc28-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 28.0%,
                    #77b872 28.1%
                    );
                }

                #custom-song.perc29-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 29.0%,
                    #77b872 29.1%
                    );
                }

                #custom-song.perc30-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 30.0%,
                    #77b872 30.1%
                    );
                }

                #custom-song.perc31-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 31.0%,
                    #77b872 31.1%
                    );
                }

                #custom-song.perc32-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 32.0%,
                    #77b872 32.1%
                    );
                }

                #custom-song.perc33-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 33.0%,
                    #77b872 33.1%
                    );
                }

                #custom-song.perc34-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 34.0%,
                    #77b872 34.1%
                    );
                }

                #custom-song.perc35-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 35.0%,
                    #77b872 35.1%
                    );
                }

                #custom-song.perc36-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 36.0%,
                    #77b872 36.1%
                    );
                }

                #custom-song.perc37-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 37.0%,
                    #77b872 37.1%
                    );
                }

                #custom-song.perc38-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 38.0%,
                    #77b872 38.1%
                    );
                }

                #custom-song.perc39-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 39.0%,
                    #77b872 39.1%
                    );
                }

                #custom-song.perc40-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 40.0%,
                    #77b872 40.1%
                    );
                }

                #custom-song.perc41-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 41.0%,
                    #77b872 41.1%
                    );
                }

                #custom-song.perc42-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 42.0%,
                    #77b872 42.1%
                    );
                }

                #custom-song.perc43-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 43.0%,
                    #77b872 43.1%
                    );
                }

                #custom-song.perc44-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 44.0%,
                    #77b872 44.1%
                    );
                }

                #custom-song.perc45-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 45.0%,
                    #77b872 45.1%
                    );
                }

                #custom-song.perc46-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 46.0%,
                    #77b872 46.1%
                    );
                }

                #custom-song.perc47-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 47.0%,
                    #77b872 47.1%
                    );
                }

                #custom-song.perc48-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 48.0%,
                    #77b872 48.1%
                    );
                }

                #custom-song.perc49-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 49.0%,
                    #77b872 49.1%
                    );
                }

                #custom-song.perc50-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 50.0%,
                    #77b872 50.1%
                    );
                }

                #custom-song.perc51-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 51.0%,
                    #77b872 51.1%
                    );
                }

                #custom-song.perc52-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 52.0%,
                    #77b872 52.1%
                    );
                }

                #custom-song.perc53-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 53.0%,
                    #77b872 53.1%
                    );
                }

                #custom-song.perc54-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 54.0%,
                    #77b872 54.1%
                    );
                }

                #custom-song.perc55-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 55.0%,
                    #77b872 55.1%
                    );
                }

                #custom-song.perc56-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 56.0%,
                    #77b872 56.1%
                    );
                }

                #custom-song.perc57-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 57.0%,
                    #77b872 57.1%
                    );
                }

                #custom-song.perc58-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 58.0%,
                    #77b872 58.1%
                    );
                }

                #custom-song.perc59-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 59.0%,
                    #77b872 59.1%
                    );
                }

                #custom-song.perc60-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 60.0%,
                    #77b872 60.1%
                    );
                }

                #custom-song.perc61-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 61.0%,
                    #77b872 61.1%
                    );
                }

                #custom-song.perc62-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 62.0%,
                    #77b872 62.1%
                    );
                }

                #custom-song.perc63-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 63.0%,
                    #77b872 63.1%
                    );
                }

                #custom-song.perc64-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 64.0%,
                    #77b872 64.1%
                    );
                }

                #custom-song.perc65-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 65.0%,
                    #77b872 65.1%
                    );
                }

                #custom-song.perc66-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 66.0%,
                    #77b872 66.1%
                    );
                }

                #custom-song.perc67-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 67.0%,
                    #77b872 67.1%
                    );
                }

                #custom-song.perc68-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 68.0%,
                    #77b872 68.1%
                    );
                }

                #custom-song.perc69-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 69.0%,
                    #77b872 69.1%
                    );
                }

                #custom-song.perc70-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 70.0%,
                    #77b872 70.1%
                    );
                }

                #custom-song.perc71-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 71.0%,
                    #77b872 71.1%
                    );
                }

                #custom-song.perc72-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 72.0%,
                    #77b872 72.1%
                    );
                }

                #custom-song.perc73-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 73.0%,
                    #77b872 73.1%
                    );
                }

                #custom-song.perc74-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 74.0%,
                    #77b872 74.1%
                    );
                }

                #custom-song.perc75-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 75.0%,
                    #77b872 75.1%
                    );
                }

                #custom-song.perc76-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 76.0%,
                    #77b872 76.1%
                    );
                }

                #custom-song.perc77-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 77.0%,
                    #77b872 77.1%
                    );
                }

                #custom-song.perc78-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 78.0%,
                    #77b872 78.1%
                    );
                }

                #custom-song.perc79-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 79.0%,
                    #77b872 79.1%
                    );
                }

                #custom-song.perc80-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 80.0%,
                    #77b872 80.1%
                    );
                }

                #custom-song.perc81-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 81.0%,
                    #77b872 81.1%
                    );
                }

                #custom-song.perc82-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 82.0%,
                    #77b872 82.1%
                    );
                }

                #custom-song.perc83-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 83.0%,
                    #77b872 83.1%
                    );
                }

                #custom-song.perc84-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 84.0%,
                    #77b872 84.1%
                    );
                }

                #custom-song.perc85-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 85.0%,
                    #77b872 85.1%
                    );
                }

                #custom-song.perc86-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 86.0%,
                    #77b872 86.1%
                    );
                }

                #custom-song.perc87-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 87.0%,
                    #77b872 87.1%
                    );
                }

                #custom-song.perc88-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 88.0%,
                    #77b872 88.1%
                    );
                }

                #custom-song.perc89-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 89.0%,
                    #77b872 89.1%
                    );
                }

                #custom-song.perc90-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 90.0%,
                    #77b872 90.1%
                    );
                }

                #custom-song.perc91-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 91.0%,
                    #77b872 91.1%
                    );
                }

                #custom-song.perc92-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 92.0%,
                    #77b872 92.1%
                    );
                }

                #custom-song.perc93-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 93.0%,
                    #77b872 93.1%
                    );
                }

                #custom-song.perc94-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 94.0%,
                    #77b872 94.1%
                    );
                }

                #custom-song.perc95-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 95.0%,
                    #77b872 95.1%
                    );
                }

                #custom-song.perc96-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 96.0%,
                    #77b872 96.1%
                    );
                }

                #custom-song.perc97-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 97.0%,
                    #77b872 97.1%
                    );
                }

                #custom-song.perc98-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 98.0%,
                    #77b872 98.1%
                    );
                }

                #custom-song.perc99-0 {
                    background-image: linear-gradient(
                    to right,
                    #a6e3a1 99.0%,
                    #77b872 99.1%
                    );
                }

                #custom-song.perc100-0 {
                    background-image: linear-gradient(
                    to right,
                        #a6e3a1 100.0%,
                        #77b872 100.1%
                    );
                }
            ''
        ];
    };
}