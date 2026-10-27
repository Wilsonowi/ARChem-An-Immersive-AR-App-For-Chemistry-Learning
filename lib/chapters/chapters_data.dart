import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/chapter_model.dart';

const List<ChapterModel> kChapters = [
  ChapterModel(
    number: 1,
    title: 'Introduction to Chemistry',
    shortTitle: 'Introduction',
    description:
        'Chemistry in daily life, scientific investigation, lab apparatus and safety.',
    icon: Icons.science_outlined,
    color: AppColors.chapter1,
    subtopics: [
      'Development in Chemistry Field',
      'Importance in Daily Life',
      'Scientific Investigation',
      'Apparatus and Materials',
    ],
  ),
  ChapterModel(
    number: 2,
    title: 'Matter and the Atomic Structure',
    shortTitle: 'Atomic Structure',
    description:
        'States of matter, atomic models, electron arrangement, isotopes and their uses.',
    icon: Icons.adjust_rounded,
    color: AppColors.chapter2,
    subtopics: [
      'Basic Concepts of Matter',
      'Development of Atomic Model',
      'Atomic Structure',
      'Isotopes and Its Uses',
    ],
  ),
  ChapterModel(
    number: 3,
    title: 'The Mole Concept, Chemical Formula and Equation',
    shortTitle: 'Mole Concept',
    description:
        'Relative atomic mass, mole concept, chemical formula and balancing equations.',
    icon: Icons.calculate_outlined,
    color: AppColors.chapter3,
    subtopics: [
      'Relative Atomic and Molecular Mass',
      'Mole Concept',
      'Chemical Formula',
      'Chemical Equation',
    ],
  ),
  ChapterModel(
    number: 4,
    title: 'The Periodic Table of Elements',
    shortTitle: 'Periodic Table',
    description:
        'History and arrangement of the periodic table, group and period trends.',
    icon: Icons.table_chart_outlined,
    color: AppColors.chapter4,
    subtopics: [
      'Development of the Periodic Table',
      'Arrangement in the Periodic Table',
      'Elements in Group 18',
      'Elements in Group 1',
      'Elements in Group 17',
      'Elements in Period 3',
      'Transition Elements',
    ],
  ),
  ChapterModel(
    number: 5,
    title: 'Chemical Bond',
    shortTitle: 'Chemical Bond',
    description:
        'Ionic, covalent, hydrogen, dative, and metallic bonds and their properties.',
    icon: Icons.hub_outlined,
    color: AppColors.chapter5,
    subtopics: [
      'Basics of Compound Formation',
      'Ionic Bond',
      'Covalent Bond',
      'Hydrogen Bond',
      'Dative Bond',
      'Metallic Bond',
      'Properties of Ionic and Covalent Compounds',
    ],
  ),
  ChapterModel(
    number: 6,
    title: 'Acid, Base and Salt',
    shortTitle: 'Acid, Base & Salt',
    description:
        'pH, acid-base reactions, salts, neutralisation, titration and qualitative analysis.',
    icon: Icons.water_drop_outlined,
    color: AppColors.chapter6,
    subtopics: [
      'Role of Water in Acidic and Alkaline Properties',
      'pH Value',
      'Strength of Acids and Alkalis',
      'Chemical Properties of Acids and Alkalis',
      'Concentration of Aqueous Solution',
      'Standard Solution',
      'Neutralisation',
      'Salts, Crystals and Their Uses',
      'Preparation of Salts',
      'Effect of Heat on Salts',
      'Qualitative Analysis',
    ],
  ),
  ChapterModel(
    number: 7,
    title: 'Rate of Reaction',
    shortTitle: 'Rate of Reaction',
    description:
        'Measuring rate, collision theory, factors affecting rate and daily life applications.',
    icon: Icons.speed_outlined,
    color: AppColors.chapter7,
    subtopics: [
      'Determining Rate of Reaction',
      'Factors Affecting Rate of Reactions',
      'Applications in Daily Life',
      'Collision Theory',
    ],
  ),
  ChapterModel(
    number: 8,
    title: 'Manufactured Substances in Industry',
    shortTitle: 'Industry',
    description:
        'Alloys, glass, ceramics, and composite materials — compositions and importance.',
    icon: Icons.factory_outlined,
    color: AppColors.chapter8,
    subtopics: [
      'Alloy and Its Importance',
      'Composition of Glass and Its Uses',
      'Composition of Ceramics and Its Uses',
      'Composite Materials and Its Importance',
    ],
  ),
];
