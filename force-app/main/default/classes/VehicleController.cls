public with sharing class VehicleController {
    @AuraEnabled(cacheable=true)
    public static List<Vehicle__c> getVehicles() {
        return [
            SELECT Id, Name, Make__c, Model__c, Year__c, Price__c, Description__c, Image_URL__c
            FROM Vehicle__c
            ORDER BY Year__c DESC NULLS LAST, Name
            LIMIT 50
        ];
    }
}
