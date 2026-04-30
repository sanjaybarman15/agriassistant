Farmer Workflow (Your Core — This is Solid)
Step 1 — Profile Creation
Farmer registers. You capture name, village, district. Village location is the anchor for everything — pest alerts, mandi prices, weather context all key off this.
Step 2 — Add Fields
From the home screen, farmer taps "Add Field." Two input options: walk to the field and drop a GPS pin, or type the location manually. You store field boundaries or at minimum a center point. Each field gets a name — "North plot," "Char land plot," etc.
Step 3 — Soil Data Entry for That Field
After adding a field, farmer (or field worker on their behalf) enters soil data — NPK values, pH, soil type, water source, irrigation availability. This is the input to your ML model.
Step 4 — ML Model Returns Top K Crops
Your model runs on the soil profile of that specific field and returns ranked crop recommendations. These are field-specific, not farm-generic. A farmer with two fields in different locations can get different recommendations for each.
Step 5 — Farmer Selects a Crop
They browse the K recommendations. When they tap one, they see the full economic breakdown — expected yield per bigha, input cost estimate, expected revenue at current mandi price, net profit estimate, sowing calendar for their district.
Step 6 — Post Harvest Loop
After the crop cycle ends, the app prompts the farmer to log new soil data for that field. This creates your soil health trend over time. Season 1 baseline, Season 2 comparison, the system shows how NPK shifted. This is the Soil Data Management feature completing its loop.
This workflow is clean and logical. Do not change it.

Field Worker Workflow (Fill the Gap)
Field workers exist because many marginal farmers cannot do soil data entry themselves — low literacy, no smartphone, no time. The field worker is the human middleware.
Their core job:
They are assigned a geographic area — a cluster of villages. They physically go to farms, collect soil samples, get them tested (or use a portable soil testing kit), and enter the results into the system on behalf of the farmer.
Their workflow in the app:
They log in to the web dashboard. They see a list of farmers assigned to their area. They select a farmer, select which field they are updating, and enter the soil test results. The system treats this exactly the same as if the farmer entered it themselves — the ML model runs, recommendations generate, and the farmer sees it on their app next time they open it.
Additional field worker actions:
They can also flag issues they observe on the ground — a pest outbreak in a specific village, crop damage from flooding, a new disease appearing. This feeds into the pest alert system for that district.
Why this role matters for your demo:
It closes the gap between "farmer cannot use technology" and "farmer receives personalized recommendation." The field worker is the last mile. Make this explicit to judges.

District Officer Workflow
District officers do not interact with individual farmers. They operate at a macro level.
Their job in your system:
They look at what is happening across all villages in their district. They see which crops are being recommended most frequently — if 70% of farmers in Barpeta are being told to plant mustard, they can plan procurement and mandi capacity accordingly.
They manage pest alerts — when a field worker reports a pest outbreak in a village, the district officer reviews it and officially publishes it as a district-wide alert. This alert then appears in every farmer's app in that affected area.
They monitor soil health trends across villages. If a cluster of villages shows declining nitrogen levels season over season, they can plan intervention — fertilizer subsidies, soil health camps.
They can also see which farmers have not received a recommendation recently — meaning their soil data is stale and a field worker needs to visit.
Their dashboard focus:
District map with farmer and alert overlays, crop distribution charts, soil health summaries by village, pest alert publish and resolve controls.

Super Admin Workflow
This is your platform operator — likely an Assam Agriculture Department official or your own team in production.
Their job:
They manage who exists in the system. They create district officer accounts and assign them to districts. They create field worker accounts and assign them to officer jurisdictions. They handle ML model updates — when your data science team trains a better model, the super admin uploads it and activates it without taking the app down.
They also see platform-wide analytics — total farmers onboarded, total recommendations generated, most active districts, system health metrics.
For the hackathon, you do not need to demo this role. Just have the accounts manageable from a simple admin panel and mention the role exists.

The Role Hierarchy Summarized Simply
Super Admin creates District Officers and owns the whole platform.
District Officer owns a district, manages field workers in their district, publishes pest alerts.
Field Worker owns a cluster of villages, visits farms, enters soil data on behalf of farmers.
Farmer owns their profile and fields, receives recommendations, logs data when they can.
Each role only sees what is relevant to their scope. A field worker cannot see another field worker's farmers. A district officer cannot see data from another district.