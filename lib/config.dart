const URL_SHORTENER = {
  'end_point': 'https://api.rebrandly.com/v1/links',
  'api_key': 'bed28c00c66b4dd28778afa8a278efc8',
  'domain': 'link.cocreations.com.au', // OR/From : 'rebrand.ly'
};

const String ADDRESSPARTOFDEEPLINK = ('https://psiapp.page.link/');

const String DEFAULT_IMAGE_SIZE = '400';

//list of image IDs that return 404 on picsum.photos
List<int> blacklisted = [
  87,
  98,
  106,
  139,
  149,
  151,
  206,
  208,
  225,
  227,
  246,
  247,
  263,
  286,
  287,
  299,
  304,
  333,
  334,
  347,
  360,
  395,
  415,
  423,
  439,
  463,
  464,
  471,
  490,
  541,
  562,
  579,
  588,
  590,
  592,
  593,
  596,
  597,
  598,
  602,
  625,
  633,
  637,
  645,
  648,
  674,
  698,
  707,
  708,
  709,
  710,
  711,
  712,
  713,
  714,
  715,
  720,
  721,
  726,
  735,
  745,
  746,
  747,
  748,
  749,
  750,
  751,
  752,
  753,
  754,
  755,
  760,
  762,
  763,
  764,
  772,
  793,
  802,
  813,
  844,
  850,
  851,
  855,
  896,
  898,
  900,
  918,
  921,
  935,
  957,
  964,
  969,
  1008,
  1018,
  1031,
  1035,
  1047,
];
