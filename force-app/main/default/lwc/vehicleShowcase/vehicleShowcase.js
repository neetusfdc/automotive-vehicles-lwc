import { LightningElement, wire } from 'lwc';
import getVehicles from '@salesforce/apex/VehicleController.getVehicles';

const FALLBACK_VEHICLES = [
    {
        id: 'fallback-roadster',
        name: 'Roadster GT',
        make: 'Acme',
        model: 'GT',
        year: 2025,
        description: 'A lightweight performance coupe for weekend drives.',
        price: '$54,900'
    },
    {
        id: 'fallback-summit',
        name: 'Summit X',
        make: 'Acme',
        model: 'X',
        year: 2024,
        description: 'A versatile electric SUV built for everyday exploration.',
        price: '$67,500'
    },
    {
        id: 'fallback-urban',
        name: 'Urban E',
        make: 'Acme',
        model: 'E',
        year: 2024,
        description: 'A compact electric hatchback with a city-friendly footprint.',
        price: '$31,250'
    }
];

export default class VehicleShowcase extends LightningElement {
    vehicles = [];
    isLoading = true;
    errorMessage;

    @wire(getVehicles)
    wiredVehicles({ data, error }) {
        this.isLoading = false;

        if (data) {
            this.errorMessage = undefined;
            this.vehicles = data.length ? data.map((vehicle) => this.toCard(vehicle)) : FALLBACK_VEHICLES;
            return;
        }

        if (error) {
            this.errorMessage = 'Vehicle records could not be loaded. Showing sample vehicles instead.';
            this.vehicles = FALLBACK_VEHICLES;
        }
    }

    toCard(vehicle) {
        return {
            id: vehicle.Id,
            name: vehicle.Name,
            make: vehicle.Make__c || 'Automotive',
            model: vehicle.Model__c || 'Vehicle',
            year: vehicle.Year__c || 'Year unavailable',
            description: vehicle.Description__c || 'No description available.',
            price: this.formatPrice(vehicle.Price__c)
        };
    }

    formatPrice(price) {
        return price === undefined || price === null
            ? 'Price on request'
            : new Intl.NumberFormat('en-US', {
                  style: 'currency',
                  currency: 'USD',
                  maximumFractionDigits: 0
              }).format(price);
    }
}
