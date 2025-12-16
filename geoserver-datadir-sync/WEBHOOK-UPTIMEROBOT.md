# How to Create a Cron / Heartbeat Monitor in UptimeRobot

This guide outlines the steps to set up a "Heartbeat" monitor in UptimeRobot. This monitor type is used to ensure that scheduled background tasks (such as database backups, data synchronization, or cron jobs) are running successfully and on time.

If the script does not "ping" UptimeRobot within the specified time window, an alert is triggered.

## Prerequisites

* Access to the [UptimeRobot Dashboard](https://uptimerobot.com/dashboard).

## Step-by-Step Configuration

1.  **Open the Monitor Dialog**
    * Navigate to the main dashboard.
    * Click the **Add New Monitor** button (usually top-left).

2.  **Select Monitor Type**
    * In the "Monitor Type" dropdown, select:
        > **Cron job / Heartbeat monitoring**

3.  **Configure Monitor Details**
    * **Friendly Name:** **(IMPORTANT)** You must follow the organization's naming convention to keep the dashboard organized.
        * **Format:** `[ORG NAME] [ENV] - [Service Name]`
        * **Correct Examples:**
            * `CIRAD PROD - GeoServer REST`
            * `CORSE PROD - Datahub`
            * `RENNES PUBLIC-PROD - GEOSERVER DATADIR SYNC`
    * **Monitoring Interval (Expectation):** Define how often UptimeRobot should expect a signal.
        * Change the time unit (e.g., switch from *minutes* to *hours*).
        * Enter the value (e.g., `1` hour).

4.  **Add Organization Tags**
    * **(IMPORTANT)** Tags must follow the standard lowercase format: `[org] [env]`.
    * In the **Add tags** section, search for or create tags that match the existing pattern.
    * **Correct Examples:**
        * `cirad prod`
        * `corse prod`
        * `rennes public prod`
        * `geo2france prod`

5.  **Configure Alert Contacts**
    * Scroll to **"How will we notify you?"** (or look at the "Integrations & Team" sidebar).
    * **Mandatory Selection:** You must select **at least two** recipients:
        1.  ✅ **`Camptocamp geOrchestra`** (Always required)
        2.  ✅ **Client Contact(s)** (Select the relevant client email/user for this project)

6.  **Finalize Creation**
    * Review your settings to ensure the interval matches your script's schedule.
    * Click the **Create monitor** button.
