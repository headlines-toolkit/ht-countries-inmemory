import 'package:ht_countries_client/ht_countries_client.dart';

/// A predefined map of initial country data, keyed by ISO code.
/// Used to seed the HtCountriesInMemoryClient by default.
final Map<String, Country> kInitialCountriesData = {
  'US': Country(
    isoCode: 'US',
    name: 'United States',
    flagUrl: 'https://example.com/flags/us.png',
  ),
  'CA': Country(
    isoCode: 'CA',
    name: 'Canada',
    flagUrl: 'https://example.com/flags/ca.png',
  ),
  'GB': Country(
    isoCode: 'GB',
    name: 'United Kingdom',
    flagUrl: 'https://example.com/flags/gb.png',
  ),
  'DE': Country(
    isoCode: 'DE',
    name: 'Germany',
    flagUrl: 'https://example.com/flags/de.png',
  ),
  'FR': Country(
    isoCode: 'FR',
    name: 'France',
    flagUrl: 'https://example.com/flags/fr.png',
  ),
  'JP': Country(
    isoCode: 'JP',
    name: 'Japan',
    flagUrl: 'https://example.com/flags/jp.png',
  ),
  'AU': Country(
    isoCode: 'AU',
    name: 'Australia',
    flagUrl: 'https://example.com/flags/au.png',
  ),
  'BR': Country(
    isoCode: 'BR',
    name: 'Brazil',
    flagUrl: 'https://example.com/flags/br.png',
  ),
  'TN': Country(
    isoCode: 'TN',
    name: 'Tunisia',
    flagUrl: 'https://example.com/flags/tn.png',
  ),
  'CN': Country(
    isoCode: 'CN',
    name: 'China',
    flagUrl: 'https://example.com/flags/cn.png',
  ),
  'RU': Country(
    isoCode: 'RU',
    name: 'Russia',
    flagUrl: 'https://example.com/flags/ru.png',
  ),
  'ZA': Country(
    isoCode: 'ZA',
    name: 'South Africa',
    flagUrl: 'https://example.com/flags/za.png',
  ),
  'MX': Country(
    isoCode: 'MX',
    name: 'Mexico',
    flagUrl: 'https://example.com/flags/mx.png',
  ),
  'AR': Country(
    isoCode: 'AR',
    name: 'Argentina',
    flagUrl: 'https://example.com/flags/ar.png',
  ),
  'IT': Country(
    isoCode: 'IT',
    name: 'Italy',
    flagUrl: 'https://example.com/flags/it.png',
  ),
  'ES': Country(
    isoCode: 'ES',
    name: 'Spain',
    flagUrl: 'https://example.com/flags/es.png',
  ),
  'KR': Country(
    isoCode: 'KR',
    name: 'South Korea',
    flagUrl: 'https://example.com/flags/kr.png',
  ),
  'SA': Country(
    isoCode: 'SA',
    name: 'Saudi Arabia',
    flagUrl: 'https://example.com/flags/sa.png',
  ),
  'NG': Country(
    isoCode: 'NG',
    name: 'Nigeria',
    flagUrl: 'https://example.com/flags/ng.png',
  ),
  'EG': Country(
    isoCode: 'EG',
    name: 'Egypt',
    flagUrl: 'https://example.com/flags/eg.png',
  ),
};
