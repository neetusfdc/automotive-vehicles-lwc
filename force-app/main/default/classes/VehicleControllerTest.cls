@IsTest
private class VehicleControllerTest {
    @IsTest
    static void returnsVehiclesOrderedByYear() {
        insert new List<Vehicle__c>{
            new Vehicle__c(
                Name = 'City Hatch',
                Make__c = 'Acme',
                Model__c = 'Urban',
                Year__c = 2024,
                Price__c = 28999,
                Description__c = 'Compact city hatchback'
            ),
            new Vehicle__c(
                Name = 'Trail Runner',
                Make__c = 'Acme',
                Model__c = 'Summit',
                Year__c = 2025,
                Price__c = 45999,
                Description__c = 'All-wheel-drive adventure SUV'
            )
        };

        Test.startTest();
        List<Vehicle__c> vehicles = VehicleController.getVehicles();
        Test.stopTest();

        System.assertEquals(2, vehicles.size());
        System.assertEquals('Trail Runner', vehicles[0].Name);
        System.assertEquals('City Hatch', vehicles[1].Name);
    }
}
