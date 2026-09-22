# Automotive Vehicles LWC

Salesforce source for an automotive vehicle showcase. The `vehicleShowcase`
Lightning Web Component reads `Vehicle__c` records through
`VehicleController.getVehicles()` and renders sample cards when no records are
available.

## Included metadata

- `Vehicle__c` with make, model, year, price, description, and image URL fields
- `VehicleController` Apex class with a cacheable, sharing-aware query
- `VehicleControllerTest` covering the query and year ordering
- `vehicleShowcase` LWC exposed on app, home, and record pages
- `OpportunityController` Apex class with a paginated, sortable Opportunity query
- `OpportunityControllerTest` covering search, stage filtering, sorting, and paging
- `opportunityList` LWC showing Opportunities in a `lightning-datatable` with name
  search, stage filter, column sorting, and pagination

## Deploy and use

1. Authenticate with a Salesforce org using Salesforce CLI.
2. Deploy the source with `sf project deploy start --source-dir force-app`.
3. Add a few `Vehicle__c` records or use the included fallback sample cards.
4. Add **Automotive Vehicle Showcase** or **Opportunity List** to a Lightning page in
   Lightning App Builder.
