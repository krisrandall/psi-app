import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:flutter/material.dart';

class LearnMoreScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: GypsyBgWrapper( 
        SingleChildScrollView( child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            SizedBox(height: 5),

            TitleText('Telepathy'),

            CopyText('Telepathy is the ability to know what is in someone else\'s mind, or to communicate with someone mentally, without using words or other physical signals.'),
           
            SizedBox(height: 10),

            TitleText('Parapsychology'),

            CopyText('Parapsychology is the study of psychic phenomena (extrasensory perception, as in telepathy, precognition, clairvoyance, psychokinesis, a.k.a. telekinesis, and psychometry) and other paranormal claims, for example related to near-death experiences, synchronicity, apparitional experiences, etc. It is considered to be pseudoscience by a vast majority of mainstream scientists, in part because, in addition to a lack of replicable empirical evidence, parapsychological claims simply cannot be true "unless the rest of science isn\'t.” That is to say, discovery of psi in scientific experiments are a direct threat to contemporary scientific paradigms.'),

            SizedBox(height: 10),

            TitleText('Psi'),

            CopyText('In parapsychology, psi is the unknown factor in extrasensory perception and psychokinesis experiences that is not explained by known physical or biological mechanisms. The term is derived from the Greek ψ psi, 23rd letter of the Greek alphabet and the initial letter of the Greek ψυχή psyche, "mind, soul".'),
            
            SizedBox(height: 10),

            TitleText('This Project'),

            CopyText('''The threat that parapsychology represents to the dogma of contemporary scientific thinking is possibly the main reason for the taboo in the scientific community around conducting studies of telepathic abilities and other psi effects.  However this challenge to the status quo of scientific thinking is not a sufficient reason to not apply the scientific process to studies of parapsychology.

This app is designed to be fun to use, but it can also be used to test for psi effects.
It is inspired by the belief that scientific inquiry should be driven by genuine curiosity to explore this incredible and mysterious world in which we find ourselves, and should not be hampered by fears of discovering that we may know less than we assume about what is really going on.
'''),

            // It would be nice to have a link to a site for 
            // learning even more here - or the ability for users
            // to donate to our cause or such like.

            SizedBox(height: 60),

        ])
        )
      )
    );
  }
        
}