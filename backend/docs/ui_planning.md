# Nevermore UI Planning
## Process from First Start
* On first start redirect to a first time admin creation link.
* Once the admin is created, log that person in as the admin.
* Redirect the user to the /setup page.
* Ask the user whether they would like to start configuring for Kiosk mode of Competition mode.
* Kiosk Mode Setup
    * Bring them to an organization setup page. (Includes name of location, logo, location.)
    * Then bring them to a Network setup page.
    * If the network is not auto-detected as setup, bring them through an interactive slideshow on how to setup the network.
    * After that, it is time to auto-detect all lights on the field by broadcasting to all devices on 10.0.101.X. (Skippable)
    * Then, do the same broadcast based auto-detection to find all sensors on the field. (Skippable)
    * Then, optionally setup a switch and AP auto-configuration.
* Redirect to the dashboard

## Routes
* / | This is the dashboard, contains useful first glance info for an admin plus all routes.
* /setup | This contains the setup page, can be rerun at any time.
* /settings | This page contains the basic event settings, like the event's name, description, logo, and other basic info.
* /settings/users | This contains a list of all users and is auto-updated, you can also update, delete, and create users here.
* /settings/referee_panel | This contains the settings for the referee panels.
* /settings/fta | This contains settings for the FTA's panel.
* /settings/audience_display | Contains settings for audience display.
* /settings/scoring_panel | This contains settings for the scoring panel.
