# Protect the Prime Minister for MTASA
![PTPM for Multi Theft Auto: San Andreas](https://stjohnsmorgue.rip/s/bQINAUiA.png)

## Description
Bikers, The Russian Mob, Stoners and Punks have gathered and are plotting to kill the Prime Minister! These terrorists
 have to be stopped! The Police Force and the PM's bodyguards have entered the fight to protect the Prime Minister
 with their lives.

## Contact
Join our development on IRC: [irc://irc.gtanet.com:6667/#PTPM](irc://irc.gtanet.com:6667/#PTPM)

Visit our forums at:
https://ptpm.uk/

## Copyright and licensing
© 2006-2016 PTPM Community (https://PTPM.uk)

Usage permitted under [GNU GPLv3](https://github.com/PTPM/MTASA/blob/master/README.md).


## Sample mtaserver.conf
```xml
<config>
    <servername>Spark's Protect The Prime Minister (https://PTPM.uk)</servername>

    <serverip>auto</serverip>

    <serverport>22003</serverport>
    <maxplayers>50</maxplayers>
    <httpport>22005</httpport>

    <!-- If Fast Download/CDN is set up -->
    <!-- <httpdownloadurl>http://play-mtasa-srv1.ptpm.uk/</httpdownloadurl> -->

    <httpmaxconnectionsperclient>8</httpmaxconnectionsperclient>
    <httpdosthreshold>20</httpdosthreshold>
    <http_dos_exclude></http_dos_exclude>

    <allow_gta3_img_mods>none</allow_gta3_img_mods>
    <disableac></disableac>
    <enablesd></enablesd>

    <minclientversion>1.5.2-9.09928.0</minclientversion>
    <minclientversion_auto_update>1</minclientversion_auto_update>
    <recommendedclientversion></recommendedclientversion>

    <ase>1</ase>
    <donotbroadcastlan>0</donotbroadcastlan>

    <password></password>

    <bandwidth_reduction>medium</bandwidth_reduction>

    <!-- Altered for potentially better sync -->
    <player_sync_interval>50</player_sync_interval>
    <keysync_mouse_sync_interval>50</keysync_mouse_sync_interval>
    <keysync_analog_sync_interval>50</keysync_analog_sync_interval>

    <lightweight_sync_interval>1500</lightweight_sync_interval>
    <camera_sync_interval>500</camera_sync_interval>
    <ped_sync_interval>400</ped_sync_interval>
    <unoccupied_vehicle_sync_interval>400</unoccupied_vehicle_sync_interval>

    <bullet_sync>1</bullet_sync>
    <latency_reduction>1</latency_reduction>

    <vehext_percent>0</vehext_percent>
    <vehext_ping_limit>150</vehext_ping_limit>


    <idfile>server-id.keys</idfile>
    <logfile>logs/server.log</logfile>
    <authfile>logs/server_auth.log</authfile>
    <dbfile>logs/db.log</dbfile>


    <acl>acl.xml</acl>

    <scriptdebuglogfile>logs/scripts.log</scriptdebuglogfile>
    <scriptdebugloglevel>0</scriptdebugloglevel>

    <htmldebuglevel>0</htmldebuglevel>

    <fpslimit>60</fpslimit>
    <autologin>0</autologin>

    <voice>0</voice>
    <voice_samplerate>1</voice_samplerate>
    <voice_quality>4</voice_quality>

    <backup_path>backups</backup_path>
    <backup_interval>3</backup_interval>
    <backup_copies>5</backup_copies>

    <compact_internal_databases>1</compact_internal_databases>

    <!-- If IRC is used -->
    <!-- <module src="ml_sockets.so" /> -->
    <!-- /If IRC is used -->

    <resource src="admin" startup="1" protected="0" />
    <resource src="defaultstats" startup="1" protected="0" />
    <resource src="helpmanager" startup="1" protected="0" />
    <resource src="joinquit" startup="1" protected="0" />

    <resource src="mapmanager" startup="1" protected="0" />
    <resource src="parachute" startup="1" protected="0" />
    <resource src="performancebrowser" startup="1" protected="0" />
    <resource src="reload" startup="1" protected="0" />
    <resource src="resourcebrowser" startup="1" protected="1" default="true" />
    <resource src="resourcemanager" startup="1" protected="1" />
    <resource src="scoreboard" startup="1" protected="0" />
    <resource src="spawnmanager" startup="1" protected="0" />
    <resource src="spectator" startup="1" protected="0" />
    <resource src="voice" startup="1" protected="0" />

    <resource src="webadmin" startup="1" protected="0" />
    <resource src="irc" startup="1" protected="0" />
    <resource src="ptpm_accounts" startup="1" protected="0" />
    <resource src="ptpm_login" startup="1" protected="0" />
    <resource src="ptpm" startup="1" protected="0" />

    <resource src="ptpm_analytics" startup="1" protected="0" />

    <resource src="killmessages" startup="1" protected="0" />
    <resource src="realdriveby" startup="1" protected="0" />
    <resource src="reload" startup="1" protected="0" />
    <resource src="heligrab" startup="1" protected="0" />
    <resource src="vending" startup="1" protected="0" />

    <resource src="antiflood" startup="1" protected="0" />

    <!-- Non-essential gameplay enhancers: -->
    <resource src="drawtag" startup="1" protected="0" />
    <resource src="drawtag_ptpm" startup="1" protected="0" />

    <resource src="headshot_special" startup="1" protected="0" />
    <resource src="antispawnkill" startup="1" protected="0" />
    <resource src="waterfps" startup="1" protected="0" />

    <resource src="interiors" startup="1" protected="0" />
    <resource src="interiorfix" startup="1" protected="0" />
</config>
```