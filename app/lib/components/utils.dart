import 'dart:convert';

import 'package:app/config.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:http/http.dart' as http;

void goToScreen(context, Widget screen) {
  Navigator.push(
      context, PageTransition(type: PageTransitionType.fade, child: screen));
}

Future<Uri> dynamicLink(String testId) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://psiapp.page.link/invite',
    link: Uri.parse('https://cocreations.com.au/psiapp-invite/ext'),
    androidParameters: AndroidParameters(
      packageName: 'au.com.cocreations.psiapp',
      minimumVersion: 0,
    ),
    iosParameters: IosParameters(
      bundleId: 'au.com.cocreations.psiapp',
      minimumVersion: '0.0.0',
      appStoreId: 'TBD... TODO',
    ),
    googleAnalyticsParameters: GoogleAnalyticsParameters(
      campaign: 'xxexample-promo',
      medium: 'xxsocial',
      source: 'xxorkut',
    ),
    itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
      providerToken: 'xx123456',
      campaignToken: 'xxexample-promo',
    ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: 'Psi Telepathy Test',
      description: 'Discover your psychic abilities.',
    ),
  );

  return await parameters.buildUrl(); // Too long !

  /* ... couldn't get the built in URL shortening to work ...
  final Uri dynamicUrl = await parameters.buildUrl();
  final ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl(
    dynamicUrl,
    DynamicLinkParametersOptions(),
  );

  return shortenedLink.shortUrl;
  */
}

Future<String> shortenLink(String url) async {
  var response = await http.post(URL_SHORTENER['end_point'],
      headers: {
        'Content-Type': 'application/json',
        'apikey': URL_SHORTENER['api_key'],
      },
      body: json.encode({
        'destination': url,
        'domain': {'fullName': URL_SHORTENER['domain']},
      }));

  Map data = jsonDecode(response.body);
  return data['shortUrl'];
}
