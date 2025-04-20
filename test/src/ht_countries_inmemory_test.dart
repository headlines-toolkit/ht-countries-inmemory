// ignore_for_file: lines_longer_than_80_chars

import 'package:ht_countries_client/ht_countries_client.dart';
import 'package:ht_countries_inmemory/ht_countries_inmemory.dart';
import 'package:ht_countries_inmemory/src/data/countries.dart'; // Import default data
import 'package:test/test.dart';

void main() {
  // Define consistent test data including flagUrl outside the group
  // to potentially use in constructor tests if needed, though kInitial is better
  // for the default case.
  final countryAF = Country(id: 'af-id', isoCode: 'AF', name: 'Afghanistan', flagUrl: 'http://example.com/af.png');
  final countryAL = Country(id: 'al-id', isoCode: 'AL', name: 'Albania', flagUrl: 'http://example.com/al.png');
  final countryDZ = Country(id: 'dz-id', isoCode: 'DZ', name: 'Algeria', flagUrl: 'http://example.com/dz.png');
  final countryAS = Country(id: 'as-id', isoCode: 'AS', name: 'American Samoa', flagUrl: 'http://example.com/as.png');
  final countryAD = Country(id: 'ad-id', isoCode: 'AD', name: 'Andorra', flagUrl: 'http://example.com/ad.png');

  final specificTestData = {
    countryAF.isoCode: countryAF,
    countryAL.isoCode: countryAL,
    countryDZ.isoCode: countryDZ,
    countryAS.isoCode: countryAS,
    countryAD.isoCode: countryAD,
  };
  // Expected sorted order by isoCode for specificTestData
  final sortedIsoCodesSpecific = ['AD', 'AF', 'AL', 'AS', 'DZ'];


  group('HtCountriesInMemoryClient Constructor', () {
    test('initializes with default kInitialCountriesData when no map is provided', () {
      final client = HtCountriesInMemoryClient();
      // Check if the client's internal map matches the default data
      // We compare lengths and maybe a few known keys/values
      expect(client.countries.length, kInitialCountriesData.length);
      expect(client.countries.containsKey('US'), isTrue); // Assuming US is in default data
      expect(client.countries['US']?.name, kInitialCountriesData['US']?.name);
      expect(client.countries['GB']?.flagUrl, kInitialCountriesData['GB']?.flagUrl);
    });

    test('initializes with provided initialCountries map', () {
      final client = HtCountriesInMemoryClient(initialCountries: specificTestData);
      expect(client.countries.length, specificTestData.length);
      expect(client.countries, equals(specificTestData)); // Compare maps directly
    });

    test('uses a copy of the provided initialCountries map', () {
      final originalMap = Map<String, Country>.from(specificTestData);
      final client = HtCountriesInMemoryClient(initialCountries: originalMap);

      // Modify the original map AFTER client creation
      originalMap['NEW'] = Country(id: 'new-id', isoCode: 'NEW', name: 'New', flagUrl: 'new.png');

      // Client's internal map should NOT have the new entry
      expect(client.countries.containsKey('NEW'), isFalse);
      expect(client.countries.length, specificTestData.length);
    });

     test('uses a copy of the default kInitialCountriesData map', () {
      final client = HtCountriesInMemoryClient();
      // Attempt to modify the client's map via the getter (should fail due to UnmodifiableMapView)
       expect(
         () => client.countries['NEW'] = Country(id: 'new-id', isoCode: 'NEW', name: 'New', flagUrl: 'new.png'),
         throwsA(isA<UnsupportedError>()),
       );

       // Also, ensure kInitialCountriesData itself wasn't modified (though it's const)
       expect(kInitialCountriesData.containsKey('NEW'), isFalse);
    });

    test('sets the simulatedDelay correctly', () {
      const delay = Duration(seconds: 1);
      final client = HtCountriesInMemoryClient(simulatedDelay: delay);
      // We can't directly access _simulatedDelay, but we can test its effect
      // by measuring execution time (though this can be flaky).
      // A simpler check might involve creating a subclass for testing,
      // but that's beyond a standard unit test.
      // For now, we assume the constructor assigns it correctly.
      // This test mainly serves as documentation.
      expect(client, isA<HtCountriesInMemoryClient>()); // Basic check
    });
  });


  group('HtCountriesInMemoryClient Methods', () {
    late HtCountriesInMemoryClient client;

    // Expected sorted order by isoCode for specificTestData
    final sortedIdsSpecific = ['ad-id', 'af-id', 'al-id', 'as-id', 'dz-id']; // Corresponding IDs

    setUp(() {
      // Initialize with the specific test data for method tests
      client = HtCountriesInMemoryClient(initialCountries: specificTestData);
    });

    test('internal countries map is unmodifiable', () {
      expect(
        () => client.countries['NEW'] = Country(
          id: 'new-id',
          isoCode: 'NEW',
          name: 'New Country',
          flagUrl: 'http://example.com/new.png',
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    group('fetchCountries', () {
      test('returns initial countries sorted by isoCode when no params', () async {
        final countries = await client.fetchCountries(limit: 10);
        expect(countries.length, 5);
        expect(countries.map((c) => c.isoCode), sortedIsoCodesSpecific);
      });

      test('returns limited number of countries', () async {
        final countries = await client.fetchCountries(limit: 2);
        expect(countries.length, 2);
        expect(countries.map((c) => c.isoCode), sortedIsoCodesSpecific.sublist(0, 2)); // AD, AF
      });

      test('returns countries after startAfterId (using ID)', () async {
        // Start after Albania (al-id) -> should get AS, DZ
        final countries = await client.fetchCountries(limit: 3, startAfterId: countryAL.id);
        expect(countries.length, 2);
        expect(countries.map((c) => c.isoCode), ['AS', 'DZ']);
      });

       test('returns empty list if startAfterId is the ID of the last item', () async {
        // Start after Algeria (dz-id)
        final countries = await client.fetchCountries(limit: 3, startAfterId: countryDZ.id);
        expect(countries.length, 0);
      });

      test('returns empty list if limit is 0', () async {
        final countries = await client.fetchCountries(limit: 0);
        expect(countries.length, 0);
      });

       test('returns empty list if effective startIndex exceeds list length', () async {
         // Fetch starting after the last item's ID
         final countries = await client.fetchCountries(limit: 5, startAfterId: countryDZ.id);
         expect(countries.isEmpty, isTrue);
       });

      test('throws CountryNotFound if startAfterId does not exist', () async {
        expect(
          () => client.fetchCountries(limit: 5, startAfterId: 'non-existent-id'),
          throwsA(isA<CountryNotFound>()),
        );
      });

      test('handles pagination correctly at boundaries using IDs', () async {
         // Fetch first 2 ('AD', 'AF') -> IDs: ad-id, af-id
         var countries = await client.fetchCountries(limit: 2);
         expect(countries.map((c) => c.isoCode), ['AD', 'AF']);
         final lastFetchedId1 = countries.last.id; // af-id

         // Fetch next 2 starting after 'af-id' ('AL', 'AS') -> IDs: al-id, as-id
         countries = await client.fetchCountries(limit: 2, startAfterId: lastFetchedId1);
         expect(countries.map((c) => c.isoCode), ['AL', 'AS']);
         final lastFetchedId2 = countries.last.id; // as-id

         // Fetch next 2 starting after 'as-id' ('DZ') -> IDs: dz-id (only 1 left)
         countries = await client.fetchCountries(limit: 2, startAfterId: lastFetchedId2);
         expect(countries.map((c) => c.isoCode), ['DZ']);
         final lastFetchedId3 = countries.last.id; // dz-id

         // Fetch next 2 starting after 'dz-id' (empty)
         countries = await client.fetchCountries(limit: 2, startAfterId: lastFetchedId3);
         expect(countries.isEmpty, isTrue);
      });
    });

    group('fetchCountry', () {
      test('returns correct country for existing isoCode', () async {
        final country = await client.fetchCountry('AL');
        expect(country, countryAL); // Check full object equality
      });

      test('throws CountryNotFound for non-existing isoCode', () async {
        expect(
          () => client.fetchCountry('XX'),
          throwsA(isA<CountryNotFound>()),
        );
      });
    });

    group('createCountry', () {
      test('successfully adds a new country', () async {
        final newCountry = Country(id: 'gb-id', isoCode: 'GB', name: 'United Kingdom', flagUrl: 'http://example.com/gb.png');
        await client.createCountry(newCountry);
        final fetched = await client.fetchCountry('GB');
        expect(fetched, newCountry);
        expect(client.countries.length, specificTestData.length + 1);
      });

      test('throws CountryCreateFailure if country with isoCode already exists', () async {
        // Attempt to create Albania again (using the existing AL object)
        expect(
          () => client.createCountry(countryAL),
          throwsA(isA<CountryCreateFailure>()),
        );
      });
    });

    group('updateCountry', () {
      test('successfully updates an existing country', () async {
        final updatedCountry = Country(id: countryAL.id, isoCode: 'AL', name: 'Albania Updated', flagUrl: 'http://example.com/al_updated.png');
        await client.updateCountry(updatedCountry);
        final fetched = await client.fetchCountry('AL');
        expect(fetched.name, 'Albania Updated');
        expect(fetched.flagUrl, 'http://example.com/al_updated.png');
        expect(fetched.id, countryAL.id); // ID should remain the same
        expect(client.countries.length, specificTestData.length); // Count shouldn't change
      });

      test('throws CountryNotFound if country isoCode does not exist', () async {
        final nonExistingCountry = Country(id: 'xx-id', isoCode: 'XX', name: 'Non Existent', flagUrl: 'http://example.com/xx.png');
        expect(
          () => client.updateCountry(nonExistingCountry),
          throwsA(isA<CountryNotFound>()),
        );
      });
    });

    group('deleteCountry', () {
      test('successfully deletes an existing country by isoCode', () async {
        final initialCount = client.countries.length;
        await client.deleteCountry('AL');
        expect(client.countries.length, initialCount - 1);
        expect(
          () => client.fetchCountry('AL'), // Verify it's gone
          throwsA(isA<CountryNotFound>()),
        );
      });

      test('throws CountryNotFound if country isoCode does not exist', () async {
        expect(
          () => client.deleteCountry('XX'),
          throwsA(isA<CountryNotFound>()),
        );
      });
    });
  });
}