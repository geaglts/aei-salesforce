The Salesforce VS Code Org Browser does not currently surface Quick Actions (“custom actions”) under object metadata. To work with them, use the CLI/Metadata API instead.

Practical paths:

- Retrieve all Quick Actions:
  - package.xml:
    - types
      - members
        - -
      - name
        - QuickAction

    - version
      - Use your API version (e.g., 60.0)

  - Command:
    - sf project retrieve start -m QuickAction

- Retrieve for a specific object (example for Account):
  - sf project retrieve start -m QuickAction:Account.\*

- Discover programmatically (Tooling API):
  - SELECT Id, DeveloperName, Label, TargetObject, Type FROM QuickActionDefinition WHERE TargetObject = 'Account'

Notes:

- Placement on layouts is part of Layout metadata, not in the QuickAction itself.
- Managed-package actions may not be retrievable depending on package exposure.
- Until Salesforce adds Org Browser support for QuickAction, use CLI/package.xml.

In Org Browser, “Tabs” support is limited; if you don’t see them, use the CLI/Metadata API. Custom tabs are the “CustomTab” metadata type.

Options:

- Retrieve all custom tabs:
  - sf project retrieve start -m CustomTab

- Retrieve a specific tab by API name:
  - sf project retrieve start -m CustomTab:My_Custom_Tab

- Retrieve multiple specific tabs:
  - sf project retrieve start -m CustomTab:My_Custom_Tab,Another_Tab

What you’ll get:

- Files under force-app/main/default/tabs/\*.tab-meta.xml for each custom tab.

Discovery tips:

- There isn’t a first-class CLI command to list tab component names; commonly you retrieve with -m CustomTab and inspect the generated names under force-app/main/default/tabs.
- Tabs created by managed packages are retrievable only if exposed by the package.

Related metadata:

- App placements are in App metadata (LightningExperienceTheme/App/Menu) not in CustomTab itself.
- If you also need custom object tabs, those are generated for objects but still represented as CustomTab metadata.

Task complete.

sf project retrieve start -m FlexiPage:Consultar_cotizaci_n
