import 'dart:async';
import 'dart:collection'; // For UnmodifiableMapView

import 'package:ht_countries_client/ht_countries_client.dart';

/// {@template ht_countries_inmemory_client}
/// An in-memory implementation of the [HtCountriesClient] interface.
///
/// This client stores and manages [Country] objects entirely in memory,
/// suitable for testing, development, or scenarios where persistence is not
/// required.
///
/// Note: This implementation is not thread-safe. Concurrent modifications
/// could lead to unexpected behavior.
/// {@endtemplate}
class HtCountriesInMemoryClient implements HtCountriesClient {
  /// {@macro ht_countries_inmemory_client}
  ///
  /// Optionally initializes the client with a pre-populated map of countries.
  /// The keys of the map should be the country ISO codes.
  HtCountriesInMemoryClient({Map<String, Country>? initialCountries})
    : _countries = initialCountries ?? {};

  /// Internal storage for countries, keyed by their ISO code.
  final Map<String, Country> _countries;

  /// Provides read-only access to the internal countries map, primarily for testing.
  Map<String, Country> get countries => UnmodifiableMapView(_countries);

  @override
  Future<List<Country>> fetchCountries({
    required int limit,
    String? startAfterId,
  }) async {
    try {
      // Sort countries by ISO code for consistent pagination
      final sortedCountries =
          _countries.values.toList()
            ..sort((a, b) => a.isoCode.compareTo(b.isoCode));

      int startIndex = 0;
      if (startAfterId != null) {
        // Find the index of the country *after* which we should start.
        // We need the ID, but our map is keyed by isoCode. We need to find
        // the country with the given ID first.
        final startAfterCountry = sortedCountries.firstWhere(
          (c) => c.id == startAfterId,
          orElse:
              () =>
                  throw CountryNotFound(
                    // Or handle differently? Contract implies fetch failure.
                    'Country with ID $startAfterId not found for pagination.',
                  ),
        );
        // Find the index of that country in the sorted list
        final startAfterIndex = sortedCountries.indexWhere(
          (c) => c.isoCode == startAfterCountry.isoCode,
        );

        if (startAfterIndex != -1) {
          startIndex = startAfterIndex + 1; // Start *after* this index
        } else {
          // This case should ideally not happen if startAfterId was valid
          // and found above, but defensively handle it.
          throw CountryFetchFailure(
            'Pagination inconsistency: Country with ID $startAfterId found but its index could not be determined.',
          );
        }
      }

      // Ensure startIndex is within bounds
      if (startIndex >= sortedCountries.length) {
        return []; // No more countries after the specified ID
      }

      // Calculate the end index, respecting the limit and list bounds
      final endIndex =
          (startIndex + limit < sortedCountries.length)
              ? startIndex + limit
              : sortedCountries.length;

      // Return the sublist for the current page
      return sortedCountries.sublist(startIndex, endIndex);
    } catch (e, s) {
      if (e is CountryNotFound) rethrow; // Allow specific exceptions
      // Wrap unexpected errors according to the contract
      throw CountryFetchFailure(e, s);
    }
  }

  @override
  Future<Country> fetchCountry(String isoCode) async {
    try {
      final country = _countries[isoCode];
      if (country == null) {
        throw CountryNotFound('Country with ISO code "$isoCode" not found.');
      }
      return country;
    } catch (e, s) {
      if (e is CountryNotFound) rethrow;
      // Wrap unexpected errors
      throw CountryFetchFailure(e, s);
    }
  }

  @override
  Future<void> createCountry(Country country) async {
    try {
      if (_countries.containsKey(country.isoCode)) {
        throw CountryCreateFailure(
          'Country with ISO code "${country.isoCode}" already exists.',
        );
      }
      _countries[country.isoCode] = country;
    } catch (e, s) {
      if (e is CountryCreateFailure) rethrow;
      // Wrap unexpected errors
      throw CountryCreateFailure(e, s);
    }
  }

  @override
  Future<void> updateCountry(Country country) async {
    try {
      if (!_countries.containsKey(country.isoCode)) {
        throw CountryNotFound(
          'Country with ISO code "${country.isoCode}" not found for update.',
        );
      }
      _countries[country.isoCode] = country; // Replace existing entry
    } catch (e, s) {
      if (e is CountryNotFound) rethrow;
      // Wrap unexpected errors
      throw CountryUpdateFailure(e, s);
    }
  }

  @override
  Future<void> deleteCountry(String isoCode) async {
    try {
      final removedCountry = _countries.remove(isoCode);
      if (removedCountry == null) {
        throw CountryNotFound(
          'Country with ISO code "$isoCode" not found for deletion.',
        );
      }
    } catch (e, s) {
      if (e is CountryNotFound) rethrow;
      // Wrap unexpected errors
      throw CountryDeleteFailure(e, s);
    }
  }
}
