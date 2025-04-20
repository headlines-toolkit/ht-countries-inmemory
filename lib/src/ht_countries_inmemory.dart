//
// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:collection'; // For UnmodifiableMapView

import 'package:ht_countries_client/ht_countries_client.dart';
import 'package:ht_countries_inmemory/src/data/countries.dart';

/// {@template ht_countries_inmemory_client}
/// An in-memory implementation of the [HtCountriesClient] interface.
///
/// This client stores and manages [Country] objects entirely in memory,
/// suitable for testing, development, or scenarios where persistence is not
/// required.
///
/// By default, it initializes with a predefined set of countries from
/// [kInitialCountriesData]. This initial data can be overridden by providing
/// a map to the constructor.
///
/// It also includes an optional simulated delay for all operations to mimic
/// network latency.
///
/// Note: This implementation is not thread-safe. Concurrent modifications
/// could lead to unexpected behavior.
/// {@endtemplate}
class HtCountriesInMemoryClient implements HtCountriesClient {
  /// {@macro ht_countries_inmemory_client}
  ///
  /// Initializes the client.
  ///
  /// If [initialCountries] is provided, it's used to populate the internal
  /// store. The keys of the map should be the country ISO codes. If null,
  /// the client is seeded with data from [kInitialCountriesData]. A *copy*
  /// is used to prevent modifications to the original constant map.
  ///
  /// [simulatedDelay]: An optional duration to wait before executing each
  /// operation, simulating network latency. Defaults to 300 milliseconds.
  HtCountriesInMemoryClient({
    Map<String, Country>? initialCountries,
    Duration simulatedDelay = const Duration(milliseconds: 300),
  }) : _countries =
           initialCountries != null
               ? Map.of(initialCountries) // Use provided data if available
               : Map.of(
                 kInitialCountriesData,
               ), // Otherwise, use a copy of default data
       _simulatedDelay = simulatedDelay;

  /// Internal storage for countries, keyed by their ISO code.
  final Map<String, Country> _countries;

  /// The duration to wait before executing operations.
  final Duration _simulatedDelay;

  /// Provides read-only access to the internal countries map,
  /// primarily for testing.
  Map<String, Country> get countries => UnmodifiableMapView(_countries);

  @override
  Future<List<Country>> fetchCountries({
    required int limit,
    String? startAfterId,
  }) async {
    await Future<void>.delayed(_simulatedDelay); // Simulate delay
    try {
      // Add limit check for extra robustness
      if (limit <= 0) {
        return [];
      }

      // Sort countries by ISO code for consistent pagination
      final sortedCountries =
          _countries.values.toList()
            ..sort((a, b) => a.isoCode.compareTo(b.isoCode));

      var startIndex = 0;
      if (startAfterId != null) {
        final startAfterCountry = sortedCountries.firstWhere(
          (c) => c.id == startAfterId,
          orElse:
              () =>
                  throw CountryNotFound(
                    'Country with ID $startAfterId not found for pagination.',
                  ),
        );
        final startAfterIndex = sortedCountries.indexWhere(
          (c) => c.isoCode == startAfterCountry.isoCode,
        );

        if (startAfterIndex != -1) {
          startIndex = startAfterIndex + 1;
        } else {
          throw CountryFetchFailure(
            'Pagination inconsistency: Country with ID $startAfterId found but its index could not be determined.',
          );
        }
      }

      if (startIndex >= sortedCountries.length) {
        return [];
      }

      final endIndex =
          (startIndex + limit < sortedCountries.length)
              ? startIndex + limit
              : sortedCountries.length;

      return sortedCountries.sublist(startIndex, endIndex);
    } catch (e, s) {
      if (e is CountryNotFound) rethrow;
      throw CountryFetchFailure(e, s);
    }
  }

  @override
  Future<Country> fetchCountry(String isoCode) async {
    await Future<void>.delayed(_simulatedDelay); // Simulate delay
    try {
      final country = _countries[isoCode];
      if (country == null) {
        throw CountryNotFound('Country with ISO code "$isoCode" not found.');
      }
      return country;
    } catch (e, s) {
      if (e is CountryNotFound) rethrow;
      throw CountryFetchFailure(e, s);
    }
  }

  @override
  Future<void> createCountry(Country country) async {
    await Future<void>.delayed(_simulatedDelay); // Simulate delay
    try {
      if (_countries.containsKey(country.isoCode)) {
        throw CountryCreateFailure(
          'Country with ISO code "${country.isoCode}" already exists.',
        );
      }
      _countries[country.isoCode] = country;
    } catch (e, s) {
      if (e is CountryCreateFailure) rethrow;
      throw CountryCreateFailure(e, s);
    }
  }

  @override
  Future<void> updateCountry(Country country) async {
    await Future<void>.delayed(_simulatedDelay); // Simulate delay
    try {
      if (!_countries.containsKey(country.isoCode)) {
        throw CountryNotFound(
          'Country with ISO code "${country.isoCode}" not found for update.',
        );
      }
      _countries[country.isoCode] = country;
    } catch (e, s) {
      if (e is CountryNotFound) rethrow;
      throw CountryUpdateFailure(e, s);
    }
  }

  @override
  Future<void> deleteCountry(String isoCode) async {
    await Future<void>.delayed(_simulatedDelay); // Simulate delay
    try {
      final removedCountry = _countries.remove(isoCode);
      if (removedCountry == null) {
        throw CountryNotFound(
          'Country with ISO code "$isoCode" not found for deletion.',
        );
      }
    } catch (e, s) {
      if (e is CountryNotFound) rethrow;
      throw CountryDeleteFailure(e, s);
    }
  }
}
