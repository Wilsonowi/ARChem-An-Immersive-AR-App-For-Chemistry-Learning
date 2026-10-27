import '../models/question_model.dart';

final List<QuestionModel> kDiagnosticQuestions = [
  QuestionModel(
    question:
        'Which field uses preservatives, colouring, and flavouring chemicals?',
    options: ['Food', 'Agriculture', 'Medicine', 'Industry'],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. The food field uses chemicals such as preservatives, colouring, flavouring, antioxidants, and stabilisers.',
    feedbackWrong:
        'Preservatives, colouring, flavouring, antioxidants, and stabilisers are chemicals used in the food field.',
    shortLabel: 'Chemicals in daily life',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Development in Chemistry Field',
  ),

  QuestionModel(
    question:
        'A chemical that decomposes easily when exposed to light, such as hydrogen peroxide, should be stored in:',
    options: [
      'Paraffin oil',
      'Dark bottles',
      'Locked metal cabinets',
      'Open shelves near sunlight',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Substances that decompose easily under light, like hydrogen peroxide and liquid bromine, are stored in dark bottles.',
    feedbackWrong:
        'Substances that decompose easily under light exposure, such as hydrogen peroxide, are stored in dark bottles to prevent decomposition.',
    shortLabel: 'Chemical storage',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Handling of Apparatus and Materials',
  ),

  QuestionModel(
    question: 'Which subatomic particle has a relative charge of +1?',
    options: ['Electron', 'Neutron', 'Proton', 'Ion'],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. A proton has a relative charge of +1 and a relative mass of 1.',
    feedbackWrong:
        'The proton carries a relative charge of +1. Electrons carry -1, and neutrons are neutral (0).',
    shortLabel: 'Subatomic particle charge',
    chapter: 'Matter and the Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Development of the Atomic Model',
  ),

  // Easy
  QuestionModel(
    question:
        'Which scientist discovered the nucleus, where protons are concentrated and almost all atomic mass is found?',
    options: ['John Dalton', 'J.J. Thomson', 'Niels Bohr', 'Ernest Rutherford'],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Ernest Rutherford discovered the nucleus containing positively-charged protons.',
    feedbackWrong:
        'Ernest Rutherford discovered the nucleus, where protons are concentrated and almost all the atomic mass is located.',
    shortLabel: 'Atomic model history',
    chapter: 'Matter and the Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Development of the Atomic Model',
  ),

  // Medium
  QuestionModel(
    question:
        'A chlorine atom has 17 protons and 18 neutrons. When it becomes a chloride ion, Cl⁻, how many electrons does it have?',
    options: ['18', '17', '16', '19'],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. A chloride ion forms when a chlorine atom gains one electron, giving it 18 electrons compared to 17 protons.',
    feedbackWrong:
        'A neutral chlorine atom has 17 electrons. Gaining one electron to form Cl⁻ gives it 18 electrons.',
    shortLabel: 'Ion electron count',
    chapter: 'Matter and the Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Atomic Structure',
  ),

  QuestionModel(
    question:
        'An atom X has a nucleon number of 23 and a proton number of 11. How many neutrons does it have?',
    options: ['11', '12', '23', '34'],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Number of neutrons = Nucleon number − Proton number = 23 − 11 = 12.',
    feedbackWrong:
        'Use: Number of neutrons = Nucleon number − Proton number. So 23 − 11 = 12 neutrons.',
    shortLabel: 'Calculating neutrons',
    chapter: 'Matter and the Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Atomic Structure',
  ),

  QuestionModel(
    question:
        'What is the SI unit used to measure the amount of substance in chemistry?',
    options: ['Gram', 'Litre', 'Mole', 'Atom'],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. The mole is the SI unit used to measure the amount of substance.',
    feedbackWrong:
        'The mole is the SI unit for amount of substance. One mole contains 6.02 × 10²³ particles.',
    shortLabel: 'SI unit of substance',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Mole Concept',
  ),

  // Easy
  QuestionModel(
    question: 'What does the symbol "(aq)" represent in a chemical equation?',
    options: ['Solid', 'Liquid', 'Gas', 'Aqueous solution'],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. (aq) represents a substance dissolved in water, i.e. an aqueous solution.',
    feedbackWrong:
        '(aq) stands for aqueous solution. (s), (l), and (g) represent solid, liquid, and gas respectively.',
    shortLabel: 'State symbols',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Chemical Equation',
  ),

  // Medium
  QuestionModel(
    question:
        'What is the relative molecular mass (RMM) of water, H₂O? [Relative atomic mass: H = 1, O = 16]',
    options: ['18', '17', '16', '34'],
    correctIndex: 0,
    feedbackCorrect: 'Correct. RMM of H₂O = 2(1) + 16 = 18.',
    feedbackWrong: 'RMM of H₂O = 2 × (RAM of H) + RAM of O = 2(1) + 16 = 18.',
    shortLabel: 'RMM of water',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Relative Atomic and Molecular Mass',
  ),

  // Hard (calculation)
  QuestionModel(
    question:
        'Calculate the number of moles in 4.0 g of sodium hydroxide, NaOH. [Relative atomic mass: Na = 23, O = 16, H = 1]',
    options: ['0.20 mol', '0.10 mol', '1.00 mol', '4.00 mol'],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Molar mass of NaOH is 40 g mol⁻¹, so number of moles = 4.0 / 40 = 0.10 mol.',
    feedbackWrong:
        'First calculate molar mass of NaOH: 23 + 16 + 1 = 40 g mol⁻¹. Then use n = mass / molar mass.',
    shortLabel: 'Moles of NaOH',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Mole Concept',
  ),

  QuestionModel(
    question:
        'In the modern Periodic Table, elements are arranged in ascending order of their:',
    options: [
      'Atomic mass',
      'Number of neutrons',
      'Proton number',
      'Number of shells',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Henry Moseley showed elements should be arranged by increasing proton number, which is the basis of the modern table.',
    feedbackWrong:
        'The modern Periodic Table arranges elements in ascending order of proton number, not atomic mass.',
    shortLabel: 'Periodic table arrangement',
    chapter: 'The Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Development of the Periodic Table',
  ),

  QuestionModel(
    question: 'Which group in the Periodic Table contains the noble gases?',
    options: ['Group 1', 'Group 17', 'Group 7', 'Group 18'],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Group 18 elements are the noble gases, such as Helium, Neon, and Argon.',
    feedbackWrong:
        'Noble gases are found in Group 18. Group 1 contains alkali metals and Group 17 contains halogens.',
    shortLabel: 'Noble gas group',
    chapter: 'The Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Group 18',
  ),

  // Medium
  QuestionModel(
    question:
        'Going down Group 1 (alkali metals), reactivity increases mainly because:',
    options: [
      'The valence electron is further from the nucleus, weakening the attraction holding it',
      'The atomic size decreases',
      'The number of valence electrons increases',
      'The melting point increases',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. A larger atomic size places the valence electron further away, weakening nuclear attraction and making it easier to donate.',
    feedbackWrong:
        'Reactivity increases down Group 1 because increasing atomic size weakens the attraction on the valence electron, making it easier to lose.',
    shortLabel: 'Group 1 reactivity trend',
    chapter: 'The Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Group 1',
  ),

  QuestionModel(
    question:
        'An element X has the electron arrangement 2.8.6. What is its Group number?',
    options: ['6', '16', '8', '14'],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. With 6 valence electrons, Group = 6 + 10 = 16 (rule applies for 3 to 8 valence electrons).',
    feedbackWrong:
        'For elements with 3 to 8 valence electrons, Group = number of valence electrons + 10. Here, 6 + 10 = 16.',
    shortLabel: 'Determining group number',
    chapter: 'The Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Arrangement in the Periodic Table',
  ),

  QuestionModel(
    question: 'An ionic bond is formed by:',
    options: [
      'Sharing of electrons between two non-metal atoms',
      'A sea of delocalised electrons around metal ions',
      'Transfer of electrons between a metal and a non-metal atom',
      'Sharing a lone pair from only one atom',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. An ionic bond forms when electrons are transferred from a metal atom to a non-metal atom.',
    feedbackWrong:
        'An ionic bond is formed by the transfer of electrons between a metal atom and a non-metal atom.',
    shortLabel: 'Ionic bond formation',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Ionic Bond',
  ),

  // Easy
  QuestionModel(
    question:
        'A metallic bond is best described as the electrostatic attraction between:',
    options: [
      'Two negatively-charged ions',
      'A metal atom and a non-metal atom transferring electrons',
      'Two non-metal atoms sharing electrons',
      'A sea of delocalised electrons and positively-charged metal ions',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Metallic bonding is the attraction between a sea of delocalised electrons and positive metal ions.',
    feedbackWrong:
        'A metallic bond is the electrostatic attraction between a "sea of electrons" and positively-charged metal ions.',
    shortLabel: 'Metallic bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Metallic Bond',
  ),

  // Medium
  QuestionModel(
    question:
        'Why do ionic compounds generally have high melting and boiling points?',
    options: [
      'Strong electrostatic attraction forces between ions require a lot of heat to overcome',
      'They have weak Van der Waals forces between molecules',
      'They are giant covalent structures with no charge',
      'They contain only non-metal atoms',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Strong electrostatic attraction forces between oppositely-charged ions require a large amount of heat energy to break.',
    feedbackWrong:
        'Ionic compounds have high melting/boiling points due to the strong electrostatic attraction forces between ions.',
    shortLabel: 'Ionic compound properties',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Properties of Ionic and Covalent Compounds',
  ),

  // Medium
  QuestionModel(
    question:
        'A dative (coordinate) bond differs from a normal covalent bond because:',
    options: [
      'Electrons are transferred, not shared',
      'The shared electron pair is contributed by only one of the two atoms',
      'It only occurs between two metal atoms',
      'No electrons are involved at all',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. In a dative bond, only one atom (with a lone pair) contributes both electrons to the shared pair.',
    feedbackWrong:
        'A dative bond is a type of covalent bond where the shared electron pair comes from only one atom, such as oxygen in water donating to H⁺.',
    shortLabel: 'Dative bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Dative Bond',
  ),

  // Hard
  QuestionModel(
    question:
        'Why can wet hair stick together while dry hair separates more easily?',
    options: [
      'Water dissolves the protein in hair completely',
      'Wet hair forms ionic bonds with water',
      'Water molecules form hydrogen bonds with protein molecules in the hair instead of the proteins bonding with each other',
      'Water increases the metallic bonding in hair',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. When hair is wet, protein molecules form hydrogen bonds with water molecules instead of with each other, causing strands to stick together.',
    feedbackWrong:
        'Wet hair sticks together because protein molecules form hydrogen bonds with water molecules rather than bonding with each other.',
    shortLabel: 'Hydrogen bonds in daily life',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Hydrogen Bond',
  ),

  QuestionModel(
    question: 'What ion causes acidity in aqueous solution?',
    options: [
      'Hydroxide ion, OH⁻',
      'Sodium ion, Na⁺',
      'Chloride ion, Cl⁻',
      'Hydrogen ion, H⁺',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Acids produce hydrogen ions, H⁺, when dissolved in water.',
    feedbackWrong:
        'Acids are acidic because they produce hydrogen ions, H⁺, in aqueous solution.',
    shortLabel: 'Acid ion',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Role of Water',
  ),

  // Easy
  QuestionModel(
    question: 'Which ion gives alkalis their alkaline properties?',
    options: [
      'Hydroxide ion, OH⁻',
      'Hydrogen ion, H⁺',
      'Carbonate ion, CO₃²⁻',
      'Ammonium ion, NH₄⁺',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Alkalis ionise in water to produce hydroxide ions, OH⁻.',
    feedbackWrong:
        'An alkali is a base that dissolves in water and ionises to produce hydroxide ions, OH⁻.',
    shortLabel: 'Alkali ion',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Role of Water',
  ),

  // Easy
  QuestionModel(
    question: 'On the pH scale, a solution with pH 3 is:',
    options: ['Alkaline', 'Acidic', 'Neutral', 'Cannot be determined'],
    correctIndex: 1,
    feedbackCorrect: 'Correct. A pH less than 7 indicates an acidic solution.',
    feedbackWrong:
        'Solutions with pH less than 7 are acidic. pH 7 is neutral, and pH greater than 7 is alkaline.',
    shortLabel: 'pH scale basics',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'pH Value',
  ),

  // Easy
  QuestionModel(
    question:
        'Hydrochloric acid, HCl, ionises completely in water. This makes it a:',
    options: ['Weak acid', 'Strong alkali', 'Strong acid', 'Weak alkali'],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. A strong acid ionises completely in water, producing a high concentration of H⁺ ions.',
    feedbackWrong:
        'HCl is a strong acid because it ionises completely in water, unlike a weak acid such as CH₃COOH.',
    shortLabel: 'Strong vs weak acid',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Strength of Acids and Alkalis',
  ),

  // Easy
  QuestionModel(
    question: 'What products are formed when an acid reacts with a base?',
    options: [
      'Salt and hydrogen gas',
      'Salt, water, and carbon dioxide gas',
      'Hydrogen gas only',
      'Salt and water',
    ],
    correctIndex: 3,
    feedbackCorrect: 'Correct. Acid + Base → Salt + Water.',
    feedbackWrong:
        'Acid reacting with a base produces salt and water only. Salt + hydrogen gas comes from acid reacting with a reactive metal.',
    shortLabel: 'Acid-base reaction',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Chemical Properties of Acids and Alkalis',
  ),

  // Medium
  QuestionModel(
    question:
        'A test tube of gas is tested with a moist red litmus paper, which turns blue. What gas is present?',
    options: [
      'Ammonia gas, NH₃',
      'Carbon dioxide gas, CO₂',
      'Chlorine gas, Cl₂',
      'Oxygen gas, O₂',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Ammonia is a pungent alkaline gas that turns moist red litmus paper blue.',
    feedbackWrong:
        'A moist red litmus paper turning blue indicates ammonia gas, NH₃, which is alkaline.',
    shortLabel: 'Gas test - ammonia',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Effect of Heat on Salts',
  ),

  // Medium
  QuestionModel(
    question:
        'According to the solubility rules, which of these chloride salts is insoluble in water?',
    options: [
      'Sodium chloride, NaCl',
      'Silver chloride, AgCl',
      'Potassium chloride, KCl',
      'Ammonium chloride, NH₄Cl',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Silver chloride is one of the exceptions; chloride salts are soluble except PbCl₂, AgCl, and Hg₂Cl₂.',
    feedbackWrong:
        'Most chloride salts are soluble, except Lead(II) chloride, Silver chloride, and Mercury(I) chloride.',
    shortLabel: 'Salt solubility rules',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Preparation of Salts',
  ),

  // Medium
  QuestionModel(
    question:
        'Adding aqueous NaOH to a salt solution produces a white precipitate that dissolves in excess NaOH. Which cation is most likely present?',
    options: [
      'Magnesium ion, Mg²⁺',
      'Calcium ion, Ca²⁺',
      'Zinc ion, Zn²⁺',
      'Iron(III) ion, Fe³⁺',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Zn²⁺ (along with Al³⁺ and Pb²⁺) forms a white precipitate that dissolves in excess NaOH.',
    feedbackWrong:
        'A white precipitate that is soluble in excess NaOH indicates Zn²⁺, Al³⁺, or Pb²⁺. Mg²⁺ and Ca²⁺ remain insoluble in excess NaOH.',
    shortLabel: 'Cation qualitative test',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Qualitative Analysis',
  ),

  // Hard (calculation)
  QuestionModel(
    question:
        'A 2.0 dm³ solution contains 0.4 mol of NaOH. What is the molarity of the solution?',
    options: ['0.4 mol dm⁻³', '0.8 mol dm⁻³', '2.0 mol dm⁻³', '0.2 mol dm⁻³'],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Molarity = number of moles / volume = 0.4 / 2.0 = 0.2 mol dm⁻³.',
    feedbackWrong:
        'Molarity (mol dm⁻³) = number of moles of solute / volume of solution (dm³) = 0.4 / 2.0 = 0.2 mol dm⁻³.',
    shortLabel: 'Calculating molarity',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Concentration of Aqueous Solution',
  ),

  // Hard (calculation)
  QuestionModel(
    question:
        '25 cm³ of 0.5 mol dm⁻³ HCl exactly neutralises 50 cm³ of NaOH solution in a 1:1 mole ratio. What is the molarity of the NaOH?',
    options: ['0.25 mol dm⁻³', '0.5 mol dm⁻³', '1.0 mol dm⁻³', '2.0 mol dm⁻³'],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Using MaVa/MbVb = a/b: (0.5 × 25)/(Mb × 50) = 1, so Mb = (0.5 × 25)/50 = 0.25 mol dm⁻³.',
    feedbackWrong:
        'Use MaVa/MbVb = a/b. With a 1:1 ratio: (0.5 × 25) = (Mb × 50), so Mb = 12.5/50 = 0.25 mol dm⁻³.',
    shortLabel: 'Titration calculation',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Neutralisation',
  ),

  // ===========================================================
  // Chapter 7 — Rate of Reaction (5 questions)
  // ===========================================================

  // Easy
  QuestionModel(
    question: 'Which of these is an example of a fast reaction?',
    options: [
      'Rusting of iron',
      'Combustion of gases',
      'Fermentation',
      'Rock erosion',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Combustion of gases (like in fireworks or matches) is a fast reaction.',
    feedbackWrong:
        'Combustion of gases is a fast reaction. Rusting, fermentation, and rock erosion are slow reactions.',
    shortLabel: 'Fast vs slow reactions',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Determining Rate of Reaction',
  ),

  // Easy
  QuestionModel(
    question: 'Which of the following increases the rate of a reaction?',
    options: [
      'Decreasing the concentration',
      'Increasing the size of solid reactant pieces',
      'Increasing the temperature',
      'Removing the catalyst',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Increasing temperature increases the kinetic energy of particles, increasing the rate of reaction.',
    feedbackWrong:
        'Increasing temperature speeds up a reaction. Larger solid pieces and lower concentration would slow the reaction down.',
    shortLabel: 'Factors affecting rate',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Factors Affecting Rate of Reactions',
  ),

  // Easy
  QuestionModel(
    question:
        'A catalyst speeds up a reaction. What happens to the mass of the catalyst by the end of the reaction?',
    options: [
      'It decreases',
      'It increases',
      'It completely disappears',
      'It remains unchanged',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. A catalyst alters the rate of reaction but remains chemically unchanged, so its mass stays the same.',
    feedbackWrong:
        'A catalyst speeds up a reaction without being consumed, so its mass remains unchanged before and after the reaction.',
    shortLabel: 'Catalyst property',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Factors Affecting Rate of Reactions',
  ),

  // Medium
  QuestionModel(
    question:
        'According to collision theory, an effective collision requires particles to collide:',
    options: [
      'With energy at least equal to the activation energy and in the correct orientation',
      'At any energy, regardless of orientation',
      'Only at very low temperatures',
      'Without touching each other',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. An effective collision needs both sufficient energy (at least the activation energy) and proper orientation.',
    feedbackWrong:
        'An effective collision occurs only if particles collide with energy ≥ activation energy and in the correct orientation.',
    shortLabel: 'Collision theory',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Collision Theory',
  ),

  // Medium
  QuestionModel(
    question: 'Why does adding a catalyst increase the rate of reaction?',
    options: [
      'It increases the temperature of the reaction',
      'It provides an alternative pathway with lower activation energy',
      'It increases the concentration of reactants',
      'It increases the volume of the container',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. A catalyst lowers the activation energy required, allowing more particles to react successfully.',
    feedbackWrong:
        'A catalyst provides an alternative reaction pathway with a lower activation energy, increasing the frequency of effective collisions.',
    shortLabel: 'Why catalysts work',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Collision Theory',
  ),

  QuestionModel(
    question: 'What is an alloy?',
    options: [
      'A pure metal with no impurities',
      'A non-metallic compound made from silica',
      'A mixture of two or more elements where the main element is a metal',
      'A type of ceramic material',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. An alloy is a mixture of two or more elements where the main element is a metal.',
    feedbackWrong:
        'An alloy is a mixture of two or more elements in which the main element is a metal, made to improve strength and hardness.',
    shortLabel: 'Definition of alloy',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Alloy and Its Importance',
  ),

  // Medium
  QuestionModel(
    question: 'Why are alloys generally harder and stronger than pure metals?',
    options: [
      'Alloys contain only non-metal atoms',
      'Alloys have weaker metallic bonds than pure metals',
      'Alloys have larger atoms that are easier to slide',
      'Foreign atoms of different sizes disrupt the orderly arrangement, preventing layers from sliding easily',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Foreign atoms of different sizes disrupt the orderly atomic arrangement, making it harder for layers to slide over each other.',
    feedbackWrong:
        'In an alloy, foreign atoms of different sizes disrupt the orderly arrangement of atoms, preventing layers from sliding, making it stronger and harder.',
    shortLabel: 'Why alloys are stronger',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Alloy and Its Importance',
  ),

  QuestionModel(
    question: 'In reinforced concrete, what is the role of the steel bars?',
    options: [
      'They act as the strengthening substance, helping the composite withstand stretching forces',
      'They act as the matrix that surrounds the concrete',
      'They make the composite material brittle',
      'They reduce the compression strength of concrete',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Steel bars are the strengthening substance, giving the composite the ability to withstand stretching forces that concrete alone cannot.',
    feedbackWrong:
        'In reinforced concrete, concrete is the matrix and steel bars are the strengthening substance, improving resistance to stretching forces.',
    shortLabel: 'Composite materials',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composite Materials and Its Importance',
  ),
];
