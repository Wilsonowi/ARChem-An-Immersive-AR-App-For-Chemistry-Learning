import '../models/question_model.dart';

final List<QuestionModel> kHardcodedQuestions = [
  // ════════════════════════════════════════════
  // CHAPTER 1 — Introduction to Chemistry
  // ════════════════════════════════════════════

  QuestionModel(
    question: 'What does the word "chemistry" originate from?',
    options: [
      'The Arabic word "al-kimiya"',
      'The Greek word "chemeia"',
      'The Latin word "alchemia"',
      'The Persian word "kimia"',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. The word chemistry originates from the Arabic word "al-kimiya".',
    feedbackWrong:
        'Chemistry originates from the Arabic word "al-kimiya", not from Greek or Latin.',
    shortLabel: 'Ch1 Origin',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Development in Chemistry',
  ),

  QuestionModel(
    question: 'Nanochemistry involves the study of particles as small as:',
    options: [
      '10⁻⁶ m',
      '10⁻⁹ m',
      '10⁻³ m',
      '10⁻¹² m',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Nanochemistry studies particles at the scale of 10⁻⁹ metres (nanometres).',
    feedbackWrong:
        'Nanochemistry studies particles at 10⁻⁹ m. 10⁻⁶ m is micrometres and 10⁻³ m is millimetres.',
    shortLabel: 'Ch1 Nano',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Development in Chemistry',
  ),

  QuestionModel(
    question: 'Which of the following chemicals is used in the food industry?',
    options: [
      'Herbicide',
      'Antibiotic',
      'Antioxidant',
      'Ceramic',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Antioxidants are commonly used in the food industry to prevent spoilage.',
    feedbackWrong:
        'Antioxidants are used in food. Herbicides are used in agriculture and antibiotics in medicine.',
    shortLabel: 'Ch1 Chemicals',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Development in Chemistry',
  ),

  QuestionModel(
    question:
        'A food scientist is an example of a career related to which chemistry field?',
    options: [
      'Pharmaceutical and Medicine',
      'Cosmetics',
      'Green Technology',
      'Nanotechnology and Food Technology',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Food scientists fall under the Nanotechnology and Food Technology field.',
    feedbackWrong:
        'Food scientists work in the Nanotechnology and Food Technology field, not medicine or cosmetics.',
    shortLabel: 'Ch1 Careers',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Development in Chemistry',
  ),

  QuestionModel(
    question:
        'Which step in the scientific method involves asking a question based on an inference?',
    options: [
      'Identifying the problem',
      'Making observations',
      'Collecting data',
      'Making a conclusion',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Identifying the problem means asking questions based on the inference made.',
    feedbackWrong:
        'Identifying the problem (asking questions from an inference) comes after making observations and inferences.',
    shortLabel: 'Ch1 Sci Method',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Scientific Investigation',
  ),

  QuestionModel(
    question:
        'In a scientific investigation, the variable that is deliberately changed is called:',
    options: [
      'Responding variable',
      'Manipulated variable',
      'Fixed variable',
      'Controlled variable',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. The manipulated variable is the one deliberately changed by the researcher.',
    feedbackWrong:
        'The variable you deliberately change is the manipulated variable. The responding variable is what you measure as a result.',
    shortLabel: 'Ch1 Variables',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Scientific Investigation',
  ),

  QuestionModel(
    question: 'What is the function of safety goggles in the laboratory?',
    options: [
      'Protects the body from chemical spills',
      'Protects the feet from sharp objects',
      'Prevents dust or chemical splashes from entering the eyes',
      'Filters toxic vapours from the air',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Safety goggles prevent dust or chemical splashes from getting into the eyes.',
    feedbackWrong:
        'Safety goggles protect the eyes from splashes and dust, not the body or feet.',
    shortLabel: 'Ch1 PPE',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Usage, Management and Handling of Apparatus',
  ),

  QuestionModel(
    question:
        'Reactive substances such as Lithium and Sodium are stored in:',
    options: [
      'Dark bottles',
      'Locked steel cabinets',
      'Shady areas away from sunlight',
      'Paraffin oil',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Reactive metals like Li and Na are stored in paraffin oil to prevent reaction with air moisture.',
    feedbackWrong:
        'Li and Na are stored in paraffin oil, not dark bottles. Dark bottles are for light-sensitive substances.',
    shortLabel: 'Ch1 Storage',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Usage, Management and Handling of Apparatus',
  ),

  QuestionModel(
    question:
        'Which equipment should be used for experiments that release toxic vapours?',
    options: [
      'Fume chamber',
      'Safety shower',
      'Eyewash station',
      'Laboratory coat',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. A fume chamber is specially designed for experiments releasing toxic vapours.',
    feedbackWrong:
        'Toxic vapour experiments must be done in a fume chamber, not under a safety shower.',
    shortLabel: 'Ch1 Fume',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Usage, Management and Handling of Apparatus',
  ),

  QuestionModel(
    question:
        'What is the FIRST step when a chemical spill occurs in the laboratory?',
    options: [
      'Clean the chemical spill right away',
      'Inform the teacher or laboratory assistant immediately',
      'Pour sand around the spill to contain it',
      'Dispose of the chemical using correct procedures',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. The first emergency step is always to inform the teacher or lab assistant immediately.',
    feedbackWrong:
        'Always inform the teacher first before attempting to clean or contain the spill yourself.',
    shortLabel: 'Ch1 Emergency',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Usage, Management and Handling of Apparatus',
  ),

  QuestionModel(
    question:
        'Organic solvents and hydrocarbons must NOT be poured down the sink because:',
    options: [
      'They are too viscous to drain',
      'They react violently with water',
      'They pollute the water source',
      'They clog the pipes',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Organic solvents and hydrocarbons pollute water sources and must be collected in special containers.',
    feedbackWrong:
        'These substances must not go down the sink because they cause water pollution, not because they clog pipes.',
    shortLabel: 'Ch1 Disposal',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Usage, Management and Handling of Apparatus',
  ),

  // ════════════════════════════════════════════
  // CHAPTER 2 — Matter and Atomic Structure
  // ════════════════════════════════════════════

  QuestionModel(
    question: 'What is the definition of matter?',
    options: [
      'Anything that can be seen and touched',
      'Any substance that contains atoms',
      'Any substance that has a fixed shape',
      'Anything that has mass and occupies space',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Matter is defined as anything that has mass and occupies space.',
    feedbackWrong:
        'Matter is defined by having mass and occupying space — not just by being visible or having a fixed shape.',
    shortLabel: 'Ch2 Matter',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Basic Concepts of Matter',
  ),

  QuestionModel(
    question:
        'Which state of matter has particles that are closely packed in an orderly manner with low kinetic energy?',
    options: [
      'Solid',
      'Liquid',
      'Gas',
      'Plasma',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. In a solid, particles are closely and orderly packed with low kinetic energy.',
    feedbackWrong:
        'Solids have closely and orderly packed particles with low kinetic energy. Gases have particles far apart with very high kinetic energy.',
    shortLabel: 'Ch2 States',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Basic Concepts of Matter',
  ),

  QuestionModel(
    question: 'Which process involves a solid changing directly into a gas?',
    options: [
      'Evaporation',
      'Sublimation',
      'Condensation',
      'Deposition',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Sublimation is the direct change of state from solid to gas without passing through the liquid state.',
    feedbackWrong:
        'The direct solid-to-gas change is sublimation. Evaporation is liquid to gas. Deposition is gas to solid.',
    shortLabel: 'Ch2 Sublimation',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Basic Concepts of Matter',
  ),

  QuestionModel(
    question: 'Who discovered the electron and proposed the plum pudding model?',
    options: [
      'Ernest Rutherford',
      'Niels Bohr',
      'J.J. Thomson',
      'James Chadwick',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. J.J. Thomson discovered the electron and proposed a positively-charged sphere with embedded electrons.',
    feedbackWrong:
        'J.J. Thomson discovered electrons. Rutherford found the nucleus. Chadwick discovered neutrons.',
    shortLabel: 'Ch2 Thomson',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Development of Atomic Model',
  ),

  QuestionModel(
    question: 'Which subatomic particle has a relative charge of +1?',
    options: [
      'Electron',
      'Neutron',
      'Nucleus',
      'Proton',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. The proton has a relative charge of +1 and is found in the nucleus.',
    feedbackWrong:
        'The proton has charge +1. The electron has charge -1. The neutron has no charge (0).',
    shortLabel: 'Ch2 Proton',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Atomic Structure',
  ),

  QuestionModel(
    question: 'The nucleon number of an atom is calculated as:',
    options: [
      'Number of protons + number of neutrons',
      'Number of protons + number of electrons',
      'Number of neutrons only',
      'Number of electrons + number of neutrons',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Nucleon number = number of protons + number of neutrons.',
    feedbackWrong:
        'Nucleon number = protons + neutrons. Electrons are not in the nucleus and do not contribute to nucleon number.',
    shortLabel: 'Ch2 Nucleon',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Atomic Structure',
  ),

  QuestionModel(
    question:
        'A chloride ion (Cl⁻) has 17 protons. How many electrons does it have?',
    options: [
      '17',
      '18',
      '16',
      '35',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Cl⁻ has gained one electron, so it has 17 + 1 = 18 electrons.',
    feedbackWrong:
        'Cl⁻ gained one electron from the neutral atom (17 electrons), giving it 18 electrons total.',
    shortLabel: 'Ch2 Chloride Ion',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Atomic Structure',
  ),

  QuestionModel(
    question: 'Isotopes of the same element have the same number of:',
    options: [
      'Neutrons but different number of protons',
      'Electrons but different number of protons',
      'Protons but different number of neutrons',
      'Protons and neutrons but different electrons',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Isotopes have the same proton number but different neutron numbers (and thus different nucleon numbers).',
    feedbackWrong:
        'Isotopes always have the SAME number of protons but DIFFERENT numbers of neutrons.',
    shortLabel: 'Ch2 Isotopes',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Isotopes and Its Uses',
  ),

  QuestionModel(
    question: 'Carbon-14 isotope is used in archaeology for:',
    options: [
      'Generating nuclear electricity',
      'Treating cancer cells',
      'Detecting pipe leakages',
      'Estimating the age of artifacts and fossils',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Carbon-14 is used for radiocarbon dating to estimate the age of artifacts and fossils.',
    feedbackWrong:
        'Carbon-14 is used for radiocarbon dating. Uranium-235 generates nuclear electricity. Cobalt-60 treats cancer.',
    shortLabel: 'Ch2 Carbon-14',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Isotopes and Its Uses',
  ),

  QuestionModel(
    question:
        'The maximum number of electrons that can be held in the second electron shell is:',
    options: [
      '8',
      '2',
      '18',
      '32',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. The second electron shell can hold a maximum of 8 electrons.',
    feedbackWrong:
        'The first shell holds a maximum of 2 electrons, the second shell holds 8, and the third shell also holds 8 for SPM-level elements.',
    shortLabel: 'Ch2 Shells',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Atomic Structure',
  ),

  QuestionModel(
    question: 'Which scientist proposed that electrons move in fixed shells around the nucleus?',
    options: [
      'John Dalton',
      'Niels Bohr',
      'James Chadwick',
      'Ernest Rutherford',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Niels Bohr proposed that electrons move in fixed shells (energy levels) around the nucleus.',
    feedbackWrong:
        'Niels Bohr proposed fixed electron shells. Rutherford discovered the nucleus. Chadwick discovered neutrons.',
    shortLabel: 'Ch2 Bohr',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Development of Atomic Model',
  ),

  // ════════════════════════════════════════════
  // CHAPTER 3 — Mole Concept, Chemical Formula and Equation
  // ════════════════════════════════════════════

  QuestionModel(
    question: 'What is one mole of any substance equal to?',
    options: [
      '1 particle',
      '12 particles',
      '6.02 × 10²³ particles',
      '24 dm³ of every substance',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. One mole contains the Avogadro constant, which is 6.02 × 10²³ particles.',
    feedbackWrong:
        'One mole represents the Avogadro constant, 6.02 × 10²³ particles.',
    shortLabel: 'Ch3 Mole',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Mole Concept',
  ),

  QuestionModel(
    question: 'What is the relative molecular mass (RMM) of water, H₂O? (H = 1, O = 16)',
    options: [
      '16',
      '17',
      '20',
      '18',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. RMM of H₂O = 2(1) + 16 = 18.',
    feedbackWrong:
        'RMM of H₂O = 2 × RAM(H) + RAM(O) = 2(1) + 16 = 18, not 16 or 17.',
    shortLabel: 'Ch3 RMM',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Relative Atomic Mass and Relative Molecular Mass',
  ),

  QuestionModel(
    question:
        'The formula n = mass / molar mass is used to find:',
    options: [
      'Number of moles from mass',
      'Number of particles from volume',
      'Volume of gas at STP',
      'Concentration of a solution',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. n = mass ÷ molar mass is the formula to calculate the number of moles from a given mass.',
    feedbackWrong:
        'n = mass ÷ molar mass gives moles from mass. To find moles from particles, use n = particles ÷ Nₐ.',
    shortLabel: 'Ch3 Moles Mass',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Mole Concept',
  ),

  QuestionModel(
    question: 'The molar volume of a gas at room conditions is:',
    options: [
      '22.4 dm³ mol⁻¹',
      '24 dm³ mol⁻¹',
      '24 cm³ mol⁻¹',
      '22.4 cm³ mol⁻¹',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. At room conditions, the molar volume of any gas is 24 dm³ mol⁻¹.',
    feedbackWrong:
        'At room conditions, molar volume = 24 dm³ mol⁻¹. At STP (standard temperature and pressure), it is 22.4 dm³ mol⁻¹.',
    shortLabel: 'Ch3 Molar Vol',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Mole Concept',
  ),

  QuestionModel(
    question:
        'The empirical formula represents:',
    options: [
      'The actual number of atoms in one molecule',
      'The molecular mass of a compound',
      'The simplest whole-number ratio of atoms in a compound',
      'The ionic formula of a salt',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. The empirical formula gives the simplest whole-number ratio of atoms present.',
    feedbackWrong:
        'Empirical formula = simplest ratio of atoms. The actual number of atoms in a molecule is the molecular formula.',
    shortLabel: 'Ch3 Empirical',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Chemical Formula',
  ),

  QuestionModel(
    question:
        'The formula of aluminium oxide, formed from Al³⁺ and O²⁻ ions, is:',
    options: [
      'AlO',
      'Al₃O₂',
      'AlO₃',
      'Al₂O₃',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Using the cross-over method: Al³⁺ and O²⁻ gives Al₂O₃.',
    feedbackWrong:
        'Cross-over the charges: Al(3+) and O(2-) → subscripts become Al₂O₃.',
    shortLabel: 'Ch3 Ionic Formula',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Chemical Formula',
  ),

  QuestionModel(
    question:
        'A balanced chemical equation must have equal numbers of:',
    options: [
      'Atoms of each element on both sides',
      'Molecules on both sides',
      'Moles on both sides',
      'Compounds on both sides',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. According to the law of conservation of mass, atoms of each element must be equal on both sides.',
    feedbackWrong:
        'The law of conservation of mass requires equal ATOMS of each element on both sides, not equal molecules or moles.',
    shortLabel: 'Ch3 Balancing',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Chemical Equation',
  ),

  QuestionModel(
    question: 'The symbol (aq) in a chemical equation means:',
    options: [
      'A gas',
      'Dissolved in water (aqueous solution)',
      'A liquid',
      'A solid',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. (aq) stands for aqueous — the substance is dissolved in water.',
    feedbackWrong:
        '(aq) = aqueous (dissolved in water). (g) = gas, (l) = liquid, (s) = solid.',
    shortLabel: 'Ch3 State Symbols',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Chemical Equation',
  ),

  QuestionModel(
    question:
        'The relative formula mass (RFM) of ZnCl₂ is: (Zn = 65, Cl = 35.5)',
    options: [
      '100.5',
      '171',
      '136',
      '65',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. RFM of ZnCl₂ = 65 + 2(35.5) = 65 + 71 = 136.',
    feedbackWrong:
        'RFM = RAM(Zn) + 2 × RAM(Cl) = 65 + 71 = 136.',
    shortLabel: 'Ch3 RFM',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Relative Atomic Mass and Relative Molecular Mass',
  ),

  QuestionModel(
    question: 'The symbol Δ placed over the arrow in a chemical equation indicates:',
    options: [
      'A catalyst is used',
      'The reaction is reversible',
      'A gas is produced',
      'Heating is required for the reaction',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. The delta symbol (Δ) over the arrow means the reaction requires heating.',
    feedbackWrong:
        'Δ over the arrow means heat is needed. A reversible reaction uses ⇌. A catalyst is written above the arrow as its formula.',
    shortLabel: 'Ch3 Delta',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Chemical Equation',
  ),

  QuestionModel(
    question:
        'Which type of substance in 1 mole contains 6.02 × 10²³ formula units?',
    options: [
      'Ionic substance',
      'Atomic substance',
      'Molecular substance',
      'Metallic substance',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Ionic substances are counted in formula units, not atoms or molecules.',
    feedbackWrong:
        'Ionic compounds are described in formula units. Metals count atoms, and covalent compounds count molecules.',
    shortLabel: 'Ch3 Formula Units',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Mole Concept',
  ),

  // ════════════════════════════════════════════
  // CHAPTER 4 — Periodic Table of Elements
  // ════════════════════════════════════════════

  QuestionModel(
    question:
        'In the modern Periodic Table, elements are arranged in order of increasing:',
    options: [
      'Atomic mass',
      'Proton number',
      'Atomic radius',
      'Melting point',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Henry Moseley showed that elements should be arranged by increasing proton number.',
    feedbackWrong:
        'The modern Periodic Table is arranged by increasing proton number, not atomic mass. Mendeleev used atomic mass in his earlier table.',
    shortLabel: 'Ch4 Arrangement',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Arrangement in the Periodic Table',
  ),

  QuestionModel(
    question:
        'An element has the electron arrangement 2.8.3. Which Group does it belong to?',
    options: [
      'Group 3',
      'Group 1',
      'Group 13',
      'Group 8',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. 3 valence electrons → Group = 3 + 10 = 13.',
    feedbackWrong:
        '3 valence electrons → Group = valence electrons + 10 = 13, because it has 3–8 valence electrons.',
    shortLabel: 'Ch4 Group',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Arrangement in the Periodic Table',
  ),

  QuestionModel(
    question: 'Why are noble gases (Group 18) chemically unreactive?',
    options: [
      'They have very large atomic radii',
      'They have very low boiling points',
      'They have no protons in their nucleus',
      'They already have a stable duplet or octet electron arrangement',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Noble gases are unreactive because they already have a full outer shell (duplet for He, octet for the rest).',
    feedbackWrong:
        'Noble gases are unreactive because their outer electron shells are already full (stable arrangement), not because of their size or boiling point.',
    shortLabel: 'Ch4 Noble Gas',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Group 18',
  ),

  QuestionModel(
    question: 'Going DOWN Group 1, the reactivity of alkali metals:',
    options: [
      'Increases',
      'Decreases',
      'Stays the same',
      'First increases then decreases',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Reactivity increases down Group 1 because the valence electron is further from the nucleus and easier to donate.',
    feedbackWrong:
        'Reactivity INCREASES down Group 1 — the valence electron is further from the nucleus, weakening attraction and making donation easier.',
    shortLabel: 'Ch4 Alkali Reactivity',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Group 1',
  ),

  QuestionModel(
    question: 'When sodium reacts with water, which gas is produced?',
    options: [
      'Oxygen gas',
      'Hydrogen gas',
      'Chlorine gas',
      'Carbon dioxide gas',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Alkali metals react with water to produce an alkaline hydroxide solution and hydrogen gas.',
    feedbackWrong:
        'Alkali metals + water → metal hydroxide (alkaline solution) + hydrogen gas, not oxygen or chlorine.',
    shortLabel: 'Ch4 Na + Water',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Group 1',
  ),

  QuestionModel(
    question: 'Going DOWN Group 17, the reactivity of halogens:',
    options: [
      'Increases',
      'Stays the same',
      'Decreases',
      'First decreases then increases',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Reactivity DECREASES down Group 17 — larger atoms attract the extra electron less strongly.',
    feedbackWrong:
        'Reactivity DECREASES down Group 17 — the opposite of Group 1. Halogens need to attract an electron; larger atoms do this less effectively.',
    shortLabel: 'Ch4 Halogen Reactivity',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Group 17',
  ),

  QuestionModel(
    question: 'Aluminium oxide (Al₂O₃) is classified as an oxide with which character?',
    options: [
      'Basic',
      'Acidic',
      'Neutral',
      'Amphoteric',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Al₂O₃ is amphoteric — it can behave as both a basic oxide and an acidic oxide.',
    feedbackWrong:
        'Al₂O₃ is amphoteric (acts as both basic and acidic). Na₂O and MgO are basic. SiO₂ and SO₂ are acidic.',
    shortLabel: 'Ch4 Al2O3',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Period 3',
  ),

  QuestionModel(
    question: 'Which transition element is used as a catalyst in the Haber Process?',
    options: [
      'Iron (Fe)',
      'Platinum (Pt)',
      'Vanadium(V) oxide (V₂O₅)',
      'Nickel (Ni)',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Iron (Fe) is the catalyst used in the Haber Process to produce ammonia (NH₃).',
    feedbackWrong:
        'Iron is used in the Haber Process. Platinum is for the Ostwald Process. V₂O₅ is for the Contact Process.',
    shortLabel: 'Ch4 Haber',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Transition Elements',
  ),

  QuestionModel(
    question: 'Copper(II) ions (Cu²⁺) in solution appear:',
    options: [
      'Green',
      'Blue',
      'Pink',
      'Orange',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Cu²⁺ ions produce a characteristic blue colour in aqueous solution.',
    feedbackWrong:
        'Cu²⁺ is blue. Fe²⁺ is green, Mn²⁺ is pink, and Cr₂O₇²⁻ is orange.',
    shortLabel: 'Ch4 Cu2+',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Transition Elements',
  ),

  QuestionModel(
    question: 'Which of the following is a use of Helium (Group 18)?',
    options: [
      'Advertising board lights',
      'Filling electric bulbs',
      'Filling weather balloons',
      'Lighthouse lamps',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Helium is used to fill weather balloons and oxygen tanks for divers.',
    feedbackWrong:
        'Helium fills balloons. Neon is used for advertising lights. Argon fills electric bulbs. Xenon is used in lighthouse lamps.',
    shortLabel: 'Ch4 Helium',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Group 18',
  ),

  QuestionModel(
    question: 'Silicon is described as a semiconductor because:',
    options: [
      'It conducts electricity perfectly at all temperatures',
      'It does not conduct electricity under any conditions',
      'It only conducts electricity when dissolved in water',
      'It conducts electricity weakly at room temperature but well at high temperatures',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Silicon is a weak conductor at room temperature but conducts well at high temperatures — the defining property of a semiconductor.',
    feedbackWrong:
        'A semiconductor like silicon has temperature-dependent conductivity — poor at room temperature, better at high temperatures.',
    shortLabel: 'Ch4 Silicon',
    chapter: 'Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Period 3',
  ),

  // ════════════════════════════════════════════
  // CHAPTER 5 — Chemical Bond
  // ════════════════════════════════════════════

  QuestionModel(
    question: 'Atoms form chemical bonds in order to:',
    options: [
      'Achieve a stable duplet or octet electron arrangement',
      'Increase their atomic mass',
      'Gain more protons',
      'Reduce their atomic radius',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Atoms bond to achieve a stable full outer shell — either a duplet (2 electrons) or an octet (8 electrons).',
    feedbackWrong:
        'Atoms bond to get a full outer shell (octet/duplet), not to change mass or gain protons.',
    shortLabel: 'Ch5 Bonding',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Basics of Compound Formation',
  ),

  QuestionModel(
    question: 'An ionic bond is formed by:',
    options: [
      'Sharing of electrons between two non-metals',
      'Transfer of electrons between a metal and a non-metal',
      'Sharing of electrons between a metal and a non-metal',
      'Transfer of protons between two atoms',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. An ionic bond forms by electron TRANSFER from a metal atom to a non-metal atom.',
    feedbackWrong:
        'Ionic bonds involve electron TRANSFER (metal to non-metal). Covalent bonds involve electron SHARING between non-metals.',
    shortLabel: 'Ch5 Ionic Bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Ionic Bond',
  ),

  QuestionModel(
    question: 'When sodium (Na) forms an ionic bond, it:',
    options: [
      'Accepts one electron to become Na⁻',
      'Shares one electron with another atom',
      'Donates one electron to become Na⁺',
      'Donates two electrons to become Na²⁺',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Na loses its single valence electron to form Na⁺, achieving a stable electron arrangement.',
    feedbackWrong:
        'Na donates (loses) 1 electron to form Na⁺, not Na⁻. It does not share or donate 2 electrons.',
    shortLabel: 'Ch5 Na Ion',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Ionic Bond',
  ),

  QuestionModel(
    question: 'A triple covalent bond involves:',
    options: [
      '1 shared pair of electrons',
      '2 shared pairs of electrons',
      '6 lone pairs of electrons',
      '3 shared pairs of electrons',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. A triple bond consists of 3 shared electron pairs, as seen in N₂ (N≡N).',
    feedbackWrong:
        'Triple bond = 3 shared pairs. Single bond = 1 pair. Double bond = 2 pairs.',
    shortLabel: 'Ch5 Triple Bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Covalent Bond',
  ),

  QuestionModel(
    question: 'Hydrogen bonds form between hydrogen and which types of atoms?',
    options: [
      'Highly electronegative atoms: N, O, or F',
      'Any metal atom',
      'Carbon atoms only',
      'Noble gas atoms',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Hydrogen bonds form when H is bonded to highly electronegative atoms: N, O, or F.',
    feedbackWrong:
        'Hydrogen bonds only form when H is attached to highly electronegative N, O, or F atoms.',
    shortLabel: 'Ch5 H Bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Hydrogen Bond',
  ),

  QuestionModel(
    question: 'A dative bond differs from a normal covalent bond because:',
    options: [
      'No electrons are shared at all',
      'Both electrons in the shared pair come from only one atom',
      'The electrons are transferred, not shared',
      'It can only form between metal atoms',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. In a dative (coordinate) bond, one atom donates BOTH electrons of the shared pair.',
    feedbackWrong:
        'In a dative bond, one atom provides both electrons. In a normal covalent bond, each atom contributes one electron to the shared pair.',
    shortLabel: 'Ch5 Dative',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Dative Bond',
  ),

  QuestionModel(
    question: 'Metals can conduct electricity because:',
    options: [
      'Their ions are positively charged',
      'They have covalent bonds that allow electron flow',
      'They have a sea of delocalised electrons that can move freely',
      'Their atoms are closely packed',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. The sea of delocalised electrons in metallic bonds can carry charge freely.',
    feedbackWrong:
        'Metals conduct electricity because of their FREE delocalised electrons — not just because of close packing or positive ions.',
    shortLabel: 'Ch5 Metallic',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Metallic Bond',
  ),

  QuestionModel(
    question: 'Ionic compounds can conduct electricity when:',
    options: [
      'In the solid state only',
      'At very high temperatures as a gas',
      'When mixed with organic solvents',
      'Dissolved in water or in the molten state',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Ionic compounds conduct electricity only when dissolved (aqueous) or molten — when ions are free to move.',
    feedbackWrong:
        'In the solid state, ions are fixed in a lattice and cannot move, so ionic compounds cannot conduct electricity as solids.',
    shortLabel: 'Ch5 Ionic Conduct',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Properties of Ionic and Covalent Compounds',
  ),

  QuestionModel(
    question: 'Which of the following has a HIGH melting point due to a giant covalent structure?',
    options: [
      'Silicon dioxide, SiO₂',
      'Water, H₂O',
      'Carbon dioxide, CO₂',
      'Sodium chloride, NaCl',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. SiO₂ is a giant covalent molecule — very strong covalent bonds must be broken to melt it.',
    feedbackWrong:
        'SiO₂ has a giant covalent structure so it has a very high melting point. H₂O and CO₂ are simple molecules with low melting points.',
    shortLabel: 'Ch5 SiO2',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Properties of Ionic and Covalent Compounds',
  ),

  QuestionModel(
    question: 'Sodium bicarbonate (NaHCO₃) used in antacids is an example of an ionic compound used in:',
    options: [
      'Agriculture',
      'Medicine',
      'Domestic cleaning',
      'Industry',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. NaHCO₃ is used in antacids to relieve gastric pain — a medical application of an ionic compound.',
    feedbackWrong:
        'NaHCO₃ in antacids is a medical use of ionic compounds. NH₄NO₃ is used in agriculture as fertiliser.',
    shortLabel: 'Ch5 NaHCO3',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Properties of Ionic and Covalent Compounds',
  ),

  QuestionModel(
    question: 'Wet hair sticking together is an example of:',
    options: [
      'Ionic bonds between water and keratin',
      'Metallic bonds in hair fibres',
      'Hydrogen bonds between water and protein molecules',
      'Covalent bonds forming between water molecules',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Water molecules form hydrogen bonds with the protein molecules in hair, causing strands to stick together when wet.',
    feedbackWrong:
        'Wet hair sticking is caused by hydrogen bonds between water molecules and hair proteins (not ionic or metallic bonds).',
    shortLabel: 'Ch5 Wet Hair',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Hydrogen Bond',
  ),

  // ════════════════════════════════════════════
  // CHAPTER 6 — Acid, Base and Salt
  // ════════════════════════════════════════════

  QuestionModel(
    question: 'Which ion causes acidity in an aqueous solution?',
    options: [
      'Hydroxide ion, OH⁻',
      'Chloride ion, Cl⁻',
      'Sodium ion, Na⁺',
      'Hydrogen ion, H⁺',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Acids produce hydrogen ions, H⁺, when dissolved in water.',
    feedbackWrong:
        'Acidity is caused by hydrogen ions (H⁺), not hydroxide ions. OH⁻ causes alkalinity.',
    shortLabel: 'Ch6 Acidity',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Role of Water in Acidic and Alkaline Properties',
  ),

  QuestionModel(
    question: 'A solution with a pH of 3 is:',
    options: [
      'Strongly acidic',
      'Weakly acidic',
      'Neutral',
      'Alkaline',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. pH 3 is well below 7, indicating a strongly acidic solution with high H⁺ concentration.',
    feedbackWrong:
        'pH 1–3 is strongly acidic. pH 4–6 is weakly acidic. pH 7 is neutral. pH above 7 is alkaline.',
    shortLabel: 'Ch6 pH',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'pH Value',
  ),

  QuestionModel(
    question: 'A STRONG acid differs from a WEAK acid because a strong acid:',
    options: [
      'Has a higher concentration',
      'Ionises completely in water',
      'Produces more molecules in solution',
      'Has a higher molecular mass',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. A strong acid ionises completely in water (shown by a single arrow →).',
    feedbackWrong:
        'Strength refers to degree of ionisation, NOT concentration. A strong acid ionises 100% in water.',
    shortLabel: 'Ch6 Strong Acid',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Strength of Acids and Alkalis',
  ),

  QuestionModel(
    question: 'Acid + Metal carbonate produces:',
    options: [
      'Salt + Hydrogen gas',
      'Salt + Water only',
      'Salt + Water + Carbon dioxide',
      'Salt + Oxygen gas',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Acid + metal carbonate → salt + water + CO₂ gas (which turns limewater cloudy).',
    feedbackWrong:
        'Acid + metal carbonate gives salt + water + CO₂. Acid + metal gives salt + H₂ gas instead.',
    shortLabel: 'Ch6 Acid Carbonate',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Chemical Properties of Acids and Alkalis',
  ),

  QuestionModel(
    question: 'The concentration formula n = MV ÷ 1000 is used when volume (V) is given in:',
    options: [
      'dm³',
      'litres',
      'mL only',
      'cm³',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. n = MV ÷ 1000 is used when volume is in cm³ (dividing by 1000 converts cm³ to dm³).',
    feedbackWrong:
        'The ÷ 1000 converts cm³ to dm³. If V is already in dm³, use n = MV directly.',
    shortLabel: 'Ch6 Concentration',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Concentration of Aqueous Solution',
  ),

  QuestionModel(
    question: 'The dilution formula M₁V₁ = M₂V₂ works because during dilution:',
    options: [
      'The number of moles of solute stays the same',
      'The concentration stays the same',
      'The volume stays the same',
      'The mass of solute decreases',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. When water is added, volume increases and concentration decreases, but the number of moles of solute is unchanged.',
    feedbackWrong:
        'Dilution adds water, which changes volume and concentration — but the total moles of solute never change.',
    shortLabel: 'Ch6 Dilution',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Standard Solution',
  ),

  QuestionModel(
    question: 'The ionic equation for neutralisation is:',
    options: [
      'Na⁺(aq) + Cl⁻(aq) → NaCl(s)',
      'H⁺(aq) + OH⁻(aq) → H₂O(l)',
      'H₂(g) + O₂(g) → H₂O(l)',
      'HCl(aq) + NaOH(aq) → NaCl(aq) + H₂O(l)',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. The actual ionic reaction in neutralisation is always H⁺ + OH⁻ → H₂O.',
    feedbackWrong:
        'The ionic equation is H⁺ + OH⁻ → H₂O. The full molecular equation includes spectator ions that are not the actual reacting species.',
    shortLabel: 'Ch6 Neutral Ionic',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Neutralisation',
  ),

  QuestionModel(
    question: 'In a titration, phenolphthalein indicator turns pink when the solution becomes:',
    options: [
      'Acidic',
      'Neutral',
      'Alkaline',
      'Saturated',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Phenolphthalein is colourless in acidic/neutral conditions and turns pink in alkaline conditions.',
    feedbackWrong:
        'Phenolphthalein = colourless in acid and neutral, PINK in alkali. Methyl orange = red in acid, orange in neutral, yellow in alkali.',
    shortLabel: 'Ch6 Phenolphthalein',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Neutralisation',
  ),

  QuestionModel(
    question: 'Which type of salt preparation is used to make INSOLUBLE salts?',
    options: [
      'Titration (neutralisation)',
      'Reacting acid with a solid metal',
      'Reacting acid with a metal oxide',
      'Double decomposition (precipitation)',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Insoluble salts are made by double decomposition — mixing two soluble salt solutions to form an insoluble precipitate.',
    feedbackWrong:
        'Insoluble salts are made by double decomposition. Titration is used for Na/K/NH₄ soluble salts.',
    shortLabel: 'Ch6 Insoluble Salt',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Preparation of Salts',
  ),

  QuestionModel(
    question: 'Which gas turns limewater cloudy?',
    options: [
      'Carbon dioxide, CO₂',
      'Hydrogen, H₂',
      'Oxygen, O₂',
      'Ammonia, NH₃',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. CO₂ reacts with limewater (calcium hydroxide solution) to form a white precipitate of calcium carbonate, turning it cloudy.',
    feedbackWrong:
        'CO₂ turns limewater cloudy. H₂ produces a pop sound with a lighted splint. O₂ rekindles a glowing splint. NH₃ turns moist red litmus blue.',
    shortLabel: 'Ch6 Limewater',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Effect of Heat on Salts',
  ),

  QuestionModel(
    question: 'A white precipitate that forms when AgNO₃(aq) is added to a solution confirms the presence of:',
    options: [
      'Sulphate ions, SO₄²⁻',
      'Chloride ions, Cl⁻',
      'Carbonate ions, CO₃²⁻',
      'Nitrate ions, NO₃⁻',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. AgNO₃ + Cl⁻ → AgCl(s), a white precipitate. This confirms chloride ions.',
    feedbackWrong:
        'White ppt with AgNO₃ → Cl⁻ present (AgCl). White ppt with BaCl₂ → SO₄²⁻ present (BaSO₄).',
    shortLabel: 'Ch6 Cl- Test',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Qualitative Analysis',
  ),

  QuestionModel(
    question: 'A green precipitate insoluble in excess NaOH and excess NH₃ indicates the presence of:',
    options: [
      'Fe³⁺ ions',
      'Cu²⁺ ions',
      'Fe²⁺ ions',
      'Zn²⁺ ions',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Fe²⁺ forms a green precipitate with NaOH/NH₃ that is insoluble in excess of either.',
    feedbackWrong:
        'Green ppt insoluble in excess = Fe²⁺. Brown ppt insoluble in excess = Fe³⁺. Blue ppt soluble in excess NH₃ = Cu²⁺.',
    shortLabel: 'Ch6 Fe2+',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Qualitative Analysis',
  ),

  // ════════════════════════════════════════════
  // CHAPTER 7 — Rate of Reaction
  // ════════════════════════════════════════════

  QuestionModel(
    question: 'The average rate of reaction is calculated using:',
    options: [
      'Mass of reactants × time',
      'Gradient of a tangent to the curve',
      'Total volume ÷ total concentration',
      'Change in quantity ÷ time taken (ΔV ÷ Δt)',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Average rate = ΔV ÷ Δt (change in quantity over the time interval).',
    feedbackWrong:
        'Average rate = ΔV ÷ Δt. The gradient of the tangent gives the INSTANTANEOUS rate at a specific moment.',
    shortLabel: 'Ch7 Avg Rate',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Determining Rate of Reaction',
  ),

  QuestionModel(
    question: 'Which of the following is an example of a SLOW reaction?',
    options: [
      'Rusting of iron (corrosion)',
      'Combustion of petrol',
      'Ignition of a match',
      'Fireworks exploding',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Corrosion/rusting of iron is a very slow reaction that takes days or even years.',
    feedbackWrong:
        'Rusting is a slow reaction. Combustion, match ignition, and fireworks are all fast reactions.',
    shortLabel: 'Ch7 Slow Rxn',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Determining Rate of Reaction',
  ),

  QuestionModel(
    question: 'Decreasing the SIZE of solid reactant particles increases the rate of reaction because:',
    options: [
      'The concentration of the solid increases',
      'The total surface area exposed to collision increases',
      'The temperature of the solid increases',
      'The solid becomes more soluble',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Smaller particles have a larger total surface area, giving more sites for reactant particles to collide.',
    feedbackWrong:
        'Smaller pieces → more surface area exposed, NOT higher concentration. More surface area = more frequent collisions.',
    shortLabel: 'Ch7 Size',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Factors Affecting Rate of Reactions',
  ),

  QuestionModel(
    question: 'Increasing temperature increases the rate of reaction because:',
    options: [
      'The activation energy of the reaction decreases',
      'The concentration of reactants increases',
      'More particles have energy greater than or equal to the activation energy',
      'More surface area is exposed',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Higher temperature means more particles have energy ≥ Eₐ, so effective collisions increase.',
    feedbackWrong:
        'Temperature does NOT lower Eₐ (that is what a catalyst does). Temperature gives MORE particles enough energy to react.',
    shortLabel: 'Ch7 Temperature',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Factors Affecting Rate of Reactions',
  ),

  QuestionModel(
    question: 'A catalyst affects the rate of reaction by:',
    options: [
      'Increasing the temperature of the reaction',
      'Increasing the concentration of reactants',
      'Being consumed in the reaction',
      'Providing an alternative pathway with lower activation energy',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. A catalyst provides an alternative pathway with lower Eₐ — and is NOT consumed in the process.',
    feedbackWrong:
        'A catalyst lowers Eₐ by providing an alternative pathway. It does NOT change temperature, concentration, or get consumed.',
    shortLabel: 'Ch7 Catalyst',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Factors Affecting Rate of Reactions',
  ),

  QuestionModel(
    question: 'A platinum catalyst in a catalytic converter converts harmful exhaust gases into:',
    options: [
      'H₂O, CO₂, and N₂',
      'CO₂ and SO₂',
      'NO and CO',
      'H₂ and O₂',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Pt in catalytic converters converts CO, NOₓ, and unburned hydrocarbons into H₂O, CO₂, and N₂.',
    feedbackWrong:
        'Catalytic converters convert harmful gases (CO, NOₓ) into safer H₂O, CO₂, and N₂ — not back into more harmful gases.',
    shortLabel: 'Ch7 Catalytic Converter',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Application of Rate of Reaction',
  ),

  QuestionModel(
    question:
        'For a collision between reactant particles to be EFFECTIVE, it must have:',
    options: [
      'Sufficient energy only',
      'Sufficient energy (≥ Eₐ) AND correct orientation',
      'Correct orientation only',
      'A catalyst present',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Both conditions are required: energy ≥ activation energy AND the correct collision orientation.',
    feedbackWrong:
        'An effective collision needs BOTH enough energy (≥ Eₐ) AND the correct orientation. Either condition alone is insufficient.',
    shortLabel: 'Ch7 Effective Collision',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Collision Theory',
  ),

  QuestionModel(
    question: 'In an EXOTHERMIC reaction energy profile, the products are:',
    options: [
      'At a higher energy level than the reactants',
      'At the same energy level as the reactants',
      'At a lower energy level than the reactants',
      'At the same level as the activation energy peak',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. In exothermic reactions, products have less energy than reactants — the difference is released as heat (ΔH is negative).',
    feedbackWrong:
        'Exothermic: products LOWER than reactants, heat is released, ΔH is negative. Endothermic: products HIGHER, heat absorbed, ΔH positive.',
    shortLabel: 'Ch7 Exothermic',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Collision Theory',
  ),

  QuestionModel(
    question: 'Storing food in a refrigerator slows decay because:',
    options: [
      'Lower temperature reduces the concentration of bacteria',
      'The cold air acts as a catalyst inhibitor',
      'The cold reduces surface area available to bacteria',
      'Lower temperature reduces the rate of bacterial activity',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Lower temperature reduces kinetic energy of particles, slowing down the rate of decay reactions.',
    feedbackWrong:
        'Refrigeration slows decay by LOWERING TEMPERATURE, which reduces reaction rate — not by changing concentration or surface area.',
    shortLabel: 'Ch7 Refrigerator',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Application of Rate of Reaction',
  ),

  QuestionModel(
    question:
        'Increasing gas pressure in a reaction increases the rate because:',
    options: [
      'It increases the concentration of gas particles per unit volume',
      'It increases the activation energy of the reaction',
      'It increases the temperature of the gas',
      'It decreases the molar mass of the gas',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Compressing a gas packs more particles into the same volume — this acts like increasing concentration.',
    feedbackWrong:
        'Pressure increases the number of gas particles per unit volume (concentration effect). It does NOT change Eₐ or temperature.',
    shortLabel: 'Ch7 Pressure',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Factors Affecting Rate of Reactions',
  ),

  // ════════════════════════════════════════════
  // CHAPTER 8 — Manufactured Substances in Industry
  // ════════════════════════════════════════════

  QuestionModel(
    question: 'An alloy is best defined as:',
    options: [
      'A pure metal that has been heated and cooled rapidly',
      'A mixture of two or more elements where the main element is a metal',
      'A compound formed between two metals',
      'A non-metallic material made at high temperature',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. An alloy is a mixture where at least one element is a metal — it is NOT a compound.',
    feedbackWrong:
        'An alloy is a MIXTURE (not a compound) of elements where the main element is a metal.',
    shortLabel: 'Ch8 Alloy',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Alloy and Its Importance',
  ),

  QuestionModel(
    question: 'Why is an alloy harder than the pure metal it is made from?',
    options: [
      'The foreign atoms bond covalently, locking the structure',
      'Alloying increases the density and compresses the atoms',
      'Foreign atoms of different sizes disrupt the orderly layer arrangement, preventing slipping',
      'The foreign atoms fill the gaps between layers, fusing them',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Different-sized foreign atoms disrupt the orderly arrangement, preventing atom layers from sliding over each other.',
    feedbackWrong:
        'Alloys are harder because differently-sized atoms DISRUPT the regular layer arrangement — layers can no longer slide easily.',
    shortLabel: 'Ch8 Alloy Hardness',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Alloy and Its Importance',
  ),

  QuestionModel(
    question: 'Duralumin is used to make the body of an aeroplane because it is:',
    options: [
      'Resistant to high temperatures',
      'A perfect electrical conductor',
      'Transparent and waterproof',
      'Strong but low density (lightweight)',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Duralumin (aluminium alloy) is used in aircraft bodies because it is strong yet lightweight.',
    feedbackWrong:
        'Duralumin is chosen for aeroplanes because it is light AND strong — the key requirement for aircraft construction.',
    shortLabel: 'Ch8 Duralumin',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Alloy and Its Importance',
  ),

  QuestionModel(
    question: 'Glass is produced by heating silica (SiO₂) with:',
    options: [
      'Other chemicals depending on the type of glass required',
      'Only pure water',
      'A carbon catalyst',
      'Metal oxides only',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Glass is made by heating SiO₂ with other chemicals — the choice of chemicals determines the type of glass.',
    feedbackWrong:
        'Different types of glass are made by heating SiO₂ with different chemicals (e.g., Na₂CO₃ for soda-lime glass, B₂O₃ for borosilicate).',
    shortLabel: 'Ch8 Glass',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composition of Glass and Its Uses',
  ),

  QuestionModel(
    question: 'Borosilicate glass contains silica plus:',
    options: [
      'Sodium carbonate (Na₂CO₃) and limestone (CaCO₃)',
      'Boron oxide (B₂O₃) and alumina (Al₂O₃)',
      'Lead components',
      'Only pure silica with no additions',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Borosilicate glass = silica + boron oxide (B₂O₃) + alumina (Al₂O₃). It is heat-resistant.',
    feedbackWrong:
        'Borosilicate = SiO₂ + B₂O₃ + Al₂O₃. Soda-lime glass = SiO₂ + Na₂CO₃ + CaCO₃.',
    shortLabel: 'Ch8 Borosilicate',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composition of Glass and Its Uses',
  ),

  QuestionModel(
    question: 'Ceramics are brittle because:',
    options: [
      'They have very low melting points',
      'They contain ionic bonds that dissolve in water',
      'Their atoms are in a rigid lattice — force breaks the bonds instead of sliding the atoms',
      'Their atoms are too small to absorb energy',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. The rigid covalent/ionic lattice in ceramics means atoms cannot slide under force — the bonds snap instead.',
    feedbackWrong:
        'Ceramics are brittle because the rigid lattice cannot deform — the strong bonds break rather than flex. Their melting points are actually very HIGH.',
    shortLabel: 'Ch8 Ceramic Brittle',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composition of Ceramics and Its Uses',
  ),

  QuestionModel(
    question: 'Zirconia ceramic is used in:',
    options: [
      'Camera flashes',
      'Cooking pots',
      'Electrical wiring',
      'Dental implants',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Zirconia ceramic is used in dental implants due to its hardness, strength, and biocompatibility.',
    feedbackWrong:
        'Zirconia ceramic → dental implants. Camera flashes use krypton. Ceramic properties make it unsuitable for flexible wiring.',
    shortLabel: 'Ch8 Zirconia',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composition of Ceramics and Its Uses',
  ),

  QuestionModel(
    question: 'In a composite material, the matrix substance:',
    options: [
      'Surrounds and binds the strengthening substance',
      'Provides the main strength and hardness',
      'Is always a metal',
      'Is always removed after the composite is formed',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. The matrix surrounds and binds the strengthening material together in a composite.',
    feedbackWrong:
        'The matrix BINDS and SURROUNDS the strengthening material. The strengthening substance provides the added structural properties.',
    shortLabel: 'Ch8 Matrix',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composite Materials and Its Importance',
  ),

  QuestionModel(
    question: 'Reinforced concrete uses steel bars to improve its ability to:',
    options: [
      'Withstand compression forces',
      'Withstand stretching forces',
      'Resist heat',
      'Resist electrical current',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Concrete resists compression well but is weak under stretching. Steel bars add tensile (stretching) strength.',
    feedbackWrong:
        'Concrete already handles COMPRESSION well. The steel is added to handle STRETCHING forces that would otherwise crack the concrete.',
    shortLabel: 'Ch8 Reinforced Concrete',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composite Materials and Its Importance',
  ),

  QuestionModel(
    question: 'Photochromic glass darkens when exposed to UV rays because it contains:',
    options: [
      'Boron oxide',
      'Lead components',
      'Silver chloride or silver halide',
      'Sodium carbonate',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Photochromic glass contains silver chloride/halide which reacts to UV light, causing the glass to darken.',
    feedbackWrong:
        'Photochromic glass contains silver chloride/halide. Boron oxide is in borosilicate glass. Lead is in crystal glass.',
    shortLabel: 'Ch8 Photochromic',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composite Materials and Its Importance',
  ),

  QuestionModel(
    question: 'The YBCO superconductor can conduct electricity:',
    options: [
      'Better than copper at room temperature',
      'Only when dissolved in water',
      'Only in alternating current circuits',
      'With zero resistance at very low temperatures',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. YBCO is a superconductor — it conducts with absolutely zero electrical resistance, but only at very low temperatures.',
    feedbackWrong:
        'YBCO is a superconductor that achieves zero resistance at very low temperatures only, not at room temperature.',
    shortLabel: 'Ch8 Superconductor',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composite Materials and Its Importance',
  ),

  // ════════════════════════════════════════════
  // NEWLY ADDED QUESTIONS — correct answers pre-varied across A-D
  // ════════════════════════════════════════════

  // ── Chapter 1 additions ──
  QuestionModel(
    question: 'Which branch of chemistry focuses on carbon-containing compounds?',
    options: [
      'Organic chemistry',
      'Inorganic chemistry',
      'Physical chemistry',
      'Analytical chemistry',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Organic chemistry is the branch that studies carbon compounds.',
    feedbackWrong:
        'Organic chemistry studies carbon compounds; inorganic chemistry covers non-carbon compounds and minerals.',
    shortLabel: 'Ch1 Branches',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Development in Chemistry',
  ),

  QuestionModel(
    question: 'A hypothesis in a scientific investigation is best described as:',
    options: [
      'A proven scientific law',
      'An educated guess that can be tested',
      'A recorded observation',
      'The final conclusion of an experiment',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. A hypothesis is a testable, educated guess made before an experiment is carried out.',
    feedbackWrong:
        'A hypothesis is an educated guess that can be tested, not a proven law or a conclusion.',
    shortLabel: 'Ch1 Hypothesis',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Scientific Investigation',
  ),

  QuestionModel(
    question:
        "Which of the following is the controlled variable in an experiment measuring how temperature affects reaction rate?",
    options: [
      'The reaction rate',
      'The temperature of the mixture',
      'The concentration and volume of acid used, kept constant',
      'The time taken for the reaction to complete',
    ],
    correctIndex: 2,
    feedbackCorrect:
        "Correct. Controlled variables are kept constant, such as the acid's concentration and volume, so only temperature affects the result.",
    feedbackWrong:
        "The controlled variable is kept constant, such as the acid's concentration and volume. Temperature is the manipulated variable and reaction rate is the responding variable.",
    shortLabel: 'Ch1 Controlled Var',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Scientific Investigation',
  ),

  QuestionModel(
    question:
        'Which apparatus is used to measure a precise, fixed volume of liquid such as 25.0 cm³?',
    options: [
      'Beaker',
      'Measuring cylinder',
      'Conical flask',
      'Pipette',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. A pipette measures and delivers one precise, fixed volume of liquid.',
    feedbackWrong:
        'A pipette delivers one precise, fixed volume. Measuring cylinders are less precise, and beakers/conical flasks are not for accurate volume measurement.',
    shortLabel: 'Ch1 Pipette',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Usage, Management and Handling of Apparatus',
  ),

  QuestionModel(
    question:
        "What should be done immediately if a chemical splashes into a student's eyes?",
    options: [
      'Rinse the eyes with plenty of running water immediately',
      'Rub the eyes to remove the chemical',
      'Wait for the teacher before doing anything',
      'Apply eye drops immediately',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. The eyes must be rinsed with plenty of running water immediately, then the teacher should be informed.',
    feedbackWrong:
        'Rinsing with plenty of running water immediately is essential — rubbing the eyes or waiting can worsen the injury.',
    shortLabel: 'Ch1 Eye Safety',
    chapter: 'Introduction to Chemistry',
    chapterNumber: 1,
    subtopic: 'Usage, Management and Handling of Apparatus',
  ),

  // ── Chapter 2 additions ──
  QuestionModel(
    question:
        'Which process involves a gas changing directly into a solid without passing through the liquid state?',
    options: [
      'Sublimation',
      'Deposition',
      'Condensation',
      'Evaporation',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Deposition is the change of state from gas directly to solid.',
    feedbackWrong:
        'Gas turning directly into a solid is called deposition. Sublimation is the reverse — solid turning directly into gas.',
    shortLabel: 'Ch2 States',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Basic Concepts of Matter',
  ),

  QuestionModel(
    question: 'According to the kinetic theory of matter, particles in a gas:',
    options: [
      'Are tightly packed in a fixed arrangement',
      'Vibrate about fixed positions only',
      'Move freely and randomly at high speed',
      'Cannot move at all',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Gas particles move freely and randomly at high speed, with large spaces between them.',
    feedbackWrong:
        'Gas particles move freely and randomly at high speed. Tightly packed, fixed-position particles describe a solid.',
    shortLabel: 'Ch2 Kinetic Theory',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Basic Concepts of Matter',
  ),

  QuestionModel(
    question:
        "Which scientist proposed that an atom is a positively charged sphere with electrons embedded in it, known as the 'plum pudding model'?",
    options: [
      'John Dalton',
      'Ernest Rutherford',
      'Niels Bohr',
      'J.J. Thomson',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. J.J. Thomson proposed the plum pudding model after discovering the electron.',
    feedbackWrong:
        'J.J. Thomson proposed the plum pudding model. Rutherford later proposed the nuclear model, and Bohr proposed electron shells.',
    shortLabel: 'Ch2 Atomic Model',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Development of Atomic Model',
  ),

  QuestionModel(
    question:
        'An atom of an element has 11 protons and 12 neutrons. What is its nucleon number?',
    options: [
      '23',
      '11',
      '12',
      '1',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Nucleon number = number of protons + number of neutrons = 11 + 12 = 23.',
    feedbackWrong:
        'Nucleon number is protons + neutrons = 11 + 12 = 23, not just the proton or neutron number alone.',
    shortLabel: 'Ch2 Nucleon Number',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Atomic Structure',
  ),

  QuestionModel(
    question: 'Cobalt-60, a radioactive isotope, is used in medicine mainly for:',
    options: [
      'Detecting leaks in underground pipes',
      'Radiotherapy to treat cancer cells',
      'Determining the age of fossils',
      'Sterilising food',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Cobalt-60 emits radiation used in radiotherapy to destroy cancer cells.',
    feedbackWrong:
        'Cobalt-60 is used in radiotherapy for cancer treatment. Carbon-14 is used for dating, and other isotopes are used for detecting leaks.',
    shortLabel: 'Ch2 Isotope Uses',
    chapter: 'Matter and Atomic Structure',
    chapterNumber: 2,
    subtopic: 'Isotopes and Its Uses',
  ),

  // ── Chapter 3 additions ──
  QuestionModel(
    question: 'What is the relative atomic mass of an element based on?',
    options: [
      'The mass of one mole of the element in grams',
      'The number of protons in one atom',
      'The average mass of one atom compared to 1/12 the mass of a carbon-12 atom',
      'The number of neutrons in the nucleus',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Relative atomic mass compares the average mass of an atom to 1/12 the mass of a carbon-12 atom.',
    feedbackWrong:
        'Relative atomic mass is defined by comparison to 1/12 the mass of a carbon-12 atom, not directly by proton or neutron count.',
    shortLabel: 'Ch3 RAM',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Relative Atomic Mass and Relative Molecular Mass',
  ),

  QuestionModel(
    question: 'How many moles of atoms are there in 12 g of carbon? (RAM of C = 12)',
    options: [
      '0.5 mol',
      '2 mol',
      '12 mol',
      '1 mol',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Number of moles = mass ÷ molar mass = 12 ÷ 12 = 1 mol.',
    feedbackWrong:
        'Number of moles = mass ÷ molar mass = 12 ÷ 12 = 1 mol, not 0.5, 2, or 12.',
    shortLabel: 'Ch3 Moles Calc',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Mole Concept',
  ),

  QuestionModel(
    question:
        'What is the empirical formula of a compound containing 40% carbon, 6.7% hydrogen, and 53.3% oxygen by mass? (C = 12, H = 1, O = 16)',
    options: [
      'CH2O',
      'C2H4O2',
      'CHO',
      'C6H12O6',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Dividing each percentage by its relative atomic mass and simplifying gives a C:H:O ratio of 1:2:1, so the empirical formula is CH2O.',
    feedbackWrong:
        'Dividing each percentage by its relative atomic mass and simplifying gives a C:H:O ratio of 1:2:1, i.e. CH2O — the simplest whole-number ratio an empirical formula shows.',
    shortLabel: 'Ch3 Empirical Formula',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Chemical Formula',
  ),

  QuestionModel(
    question: 'Balance the equation: __Mg + __O2 -> __MgO. What are the correct coefficients, in order?',
    options: [
      '1, 1, 1',
      '2, 1, 2',
      '1, 2, 2',
      '2, 2, 1',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. 2Mg + O2 -> 2MgO balances both magnesium and oxygen atoms on each side.',
    feedbackWrong:
        'The balanced equation is 2Mg + O2 -> 2MgO — this balances both the magnesium and oxygen atoms on each side.',
    shortLabel: 'Ch3 Balancing',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Chemical Equation',
  ),

  QuestionModel(
    question: 'In the equation CaCO3 -> CaO + CO2, what type of reaction is represented?',
    options: [
      'Combustion',
      'Neutralisation',
      'Thermal decomposition',
      'Precipitation',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Heating calcium carbonate to break it down into calcium oxide and carbon dioxide is a thermal decomposition reaction.',
    feedbackWrong:
        'This is a thermal decomposition reaction — a single compound breaking down into simpler substances when heated.',
    shortLabel: 'Ch3 Reaction Types',
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    subtopic: 'Chemical Equation',
  ),

  // ── Chapter 4 additions ──
  QuestionModel(
    question:
        "Who rearranged the periodic table based on increasing atomic (proton) number, resolving inconsistencies in Mendeleev's earlier table?",
    options: [
      'Antoine Lavoisier',
      'John Newlands',
      'Dmitri Mendeleev',
      'Henry Moseley',
    ],
    correctIndex: 3,
    feedbackCorrect:
        "Correct. Henry Moseley rearranged the periodic table by proton number, fixing inconsistencies in Mendeleev's mass-based arrangement.",
    feedbackWrong:
        "Henry Moseley rearranged elements by proton number. Mendeleev's earlier table was based on atomic mass and had some inconsistencies.",
    shortLabel: 'Ch4 History',
    chapter: 'The Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Development of the Periodic Table',
  ),

  QuestionModel(
    question: 'Elements in the same group of the periodic table have the same:',
    options: [
      'Number of valence electrons',
      'Number of electron shells',
      'Atomic size',
      'Nucleon number',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Elements in the same group have the same number of valence electrons, giving them similar chemical properties.',
    feedbackWrong:
        'Elements in the same group share the same number of valence electrons. The number of shells increases down a group instead, matching the period number.',
    shortLabel: 'Ch4 Groups',
    chapter: 'The Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Arrangement in the Periodic Table',
  ),

  QuestionModel(
    question: 'Why are the noble gases (Group 18) generally unreactive?',
    options: [
      'They have very high melting points',
      'They have a stable, fully-filled valence electron shell',
      'They are all radioactive',
      'They have too few protons to react',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Noble gases have a full valence electron shell, giving them a stable electron arrangement and very low reactivity.',
    feedbackWrong:
        'Noble gases are unreactive because their valence shell is already full and stable, not because of melting point or radioactivity.',
    shortLabel: 'Ch4 Noble Gases',
    chapter: 'The Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Group 18',
  ),

  QuestionModel(
    question: 'Down Group 1 (alkali metals), reactivity with water:',
    options: [
      'Decreases',
      'Stays the same',
      'Increases',
      'Becomes zero',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Reactivity increases down Group 1 because the valence electron is further from the nucleus and more easily lost.',
    feedbackWrong:
        'Reactivity increases down Group 1, since the valence electron becomes easier to lose as atomic size increases down the group.',
    shortLabel: 'Ch4 Group 1 Trend',
    chapter: 'The Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Elements in Group 1',
  ),

  QuestionModel(
    question: 'Which property generally describes the transition elements?',
    options: [
      'They form only colourless compounds',
      'They exist only as gases at room temperature',
      'They cannot act as catalysts',
      'They can form ions with different charges and coloured compounds',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Transition elements typically form ions of variable charge and coloured compounds, and are often used as catalysts.',
    feedbackWrong:
        'Transition elements form ions of variable charge and coloured compounds, and many act as catalysts — the opposite of these other statements.',
    shortLabel: 'Ch4 Transition',
    chapter: 'The Periodic Table of Elements',
    chapterNumber: 4,
    subtopic: 'Transition Elements',
  ),

  // ── Chapter 5 additions ──
  QuestionModel(
    question: 'An ionic bond forms through:',
    options: [
      'The transfer of electrons from a metal atom to a non-metal atom',
      'The sharing of electron pairs between two non-metal atoms',
      'The sharing of a lone pair of electrons from one atom',
      'The overlapping of delocalised electrons',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. An ionic bond forms when electrons are transferred from a metal atom to a non-metal atom, forming oppositely charged ions.',
    feedbackWrong:
        'Ionic bonds form through electron transfer, typically from metal to non-metal. Sharing electrons describes covalent bonding instead.',
    shortLabel: 'Ch5 Ionic Bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Ionic Bond',
  ),

  QuestionModel(
    question: 'A single covalent bond is formed by:',
    options: [
      'Transferring one electron between two atoms',
      'Sharing one pair of electrons between two atoms',
      'Sharing three pairs of electrons',
      'Transferring two electrons',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. A single covalent bond is formed by one shared pair of electrons between two atoms.',
    feedbackWrong:
        'A single covalent bond involves sharing exactly one pair of electrons, not electron transfer.',
    shortLabel: 'Ch5 Covalent Bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Covalent Bond',
  ),

  QuestionModel(
    question:
        'A hydrogen bond can form between molecules where hydrogen is directly bonded to which highly electronegative elements?',
    options: [
      'Carbon, sulfur, and phosphorus',
      'Chlorine and bromine only',
      'Nitrogen, oxygen, and fluorine',
      'Any non-metal element',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Hydrogen bonding occurs when hydrogen is bonded to a strongly electronegative atom — nitrogen, oxygen, or fluorine.',
    feedbackWrong:
        'Hydrogen bonds form specifically when hydrogen is bonded to nitrogen, oxygen, or fluorine, due to their high electronegativity.',
    shortLabel: 'Ch5 Hydrogen Bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Hydrogen Bond',
  ),

  QuestionModel(
    question: 'A dative (coordinate) bond differs from a normal covalent bond because:',
    options: [
      'It only forms between two metal atoms',
      'No electrons are shared at all',
      'It involves the transfer of electrons instead of sharing',
      'Both shared electrons come from the same atom',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. In a dative bond, both electrons of the shared pair come from just one of the two atoms.',
    feedbackWrong:
        'In a dative bond, both electrons of the shared pair come from a single atom, unlike a normal covalent bond where each atom contributes one electron.',
    shortLabel: 'Ch5 Dative Bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Dative Bond',
  ),

  QuestionModel(
    question: 'Metallic bonding can be described as:',
    options: [
      "The electrostatic attraction between metal cations and a 'sea' of delocalised electrons",
      'The sharing of electrons between two metal atoms only',
      'The transfer of electrons between metal atoms',
      'Hydrogen bonding between metal atoms',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Metallic bonding is the strong electrostatic attraction between positive metal ions and delocalised (free-moving) electrons.',
    feedbackWrong:
        'Metallic bonding is the attraction between metal cations and delocalised electrons, not electron sharing or transfer between metal atoms.',
    shortLabel: 'Ch5 Metallic Bond',
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    subtopic: 'Metallic Bond',
  ),

  // ── Chapter 6 additions ──
  QuestionModel(
    question: 'A solution with pH 3 is:',
    options: [
      'Strongly alkaline',
      'Strongly acidic',
      'Neutral',
      'Weakly alkaline',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. A pH of 3 is well below 7, indicating a strongly acidic solution.',
    feedbackWrong:
        'pH values below 7 indicate acidity, and the further below 7, the stronger the acid — pH 3 is strongly acidic.',
    shortLabel: 'Ch6 pH',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'pH Value',
  ),

  QuestionModel(
    question: 'What determines whether an acid is classified as strong or weak?',
    options: [
      'Its concentration in mol/dm3',
      'Its physical state (liquid or solid)',
      'The degree to which it ionises in water',
      'Its molecular mass',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. A strong acid ionises completely in water, while a weak acid only partially ionises.',
    feedbackWrong:
        'Acid strength depends on the degree of ionisation in water, not concentration — a dilute strong acid is still a strong acid.',
    shortLabel: 'Ch6 Strength',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Strength of Acids and Alkalis',
  ),

  QuestionModel(
    question: 'Which gas is produced when a reactive metal reacts with a dilute acid?',
    options: [
      'Oxygen',
      'Carbon dioxide',
      'Ammonia',
      'Hydrogen',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Metal + acid reactions produce hydrogen gas and a salt.',
    feedbackWrong:
        "Metal + acid reactions produce hydrogen gas, tested with a lit splint that gives a 'pop' sound — not carbon dioxide or ammonia.",
    shortLabel: 'Ch6 Metal+Acid',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Chemical Properties of Acids and Alkalis',
  ),

  QuestionModel(
    question:
        '0.5 mol of NaOH is dissolved to make 250 cm3 of solution. What is its concentration in mol/dm3?',
    options: [
      '2 mol dm-3',
      '0.5 mol dm-3',
      '0.125 mol dm-3',
      '4 mol dm-3',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. Concentration = moles ÷ volume in dm3 = 0.5 ÷ 0.25 = 2 mol dm-3.',
    feedbackWrong:
        'Concentration = moles ÷ volume in dm3 = 0.5 ÷ 0.25 = 2 mol dm-3, not 0.5, 0.125, or 4.',
    shortLabel: 'Ch6 Concentration',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Concentration of Aqueous Solution',
  ),

  QuestionModel(
    question: 'In a neutralisation reaction, an acid reacts with a base to form:',
    options: [
      'A gas and water only',
      'A salt and water',
      'Two different acids',
      'A precipitate only',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Neutralisation is the reaction between an acid and a base, producing a salt and water.',
    feedbackWrong:
        'Neutralisation always produces a salt and water — not a gas alone or a precipitate.',
    shortLabel: 'Ch6 Neutralisation',
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    subtopic: 'Neutralisation',
  ),

  // ── Chapter 7 additions ──
  QuestionModel(
    question: 'Rate of reaction can be measured by monitoring:',
    options: [
      'The colour of the container',
      'The temperature of the room',
      'The volume of gas produced over time',
      'The mass of the reactants before mixing',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Rate of reaction is commonly measured by tracking the volume of gas produced, mass loss, or time taken for a visual change, over time.',
    feedbackWrong:
        'Rate of reaction is measured by monitoring a changing quantity over time, such as gas volume produced — not by static, before-mixing measurements.',
    shortLabel: 'Ch7 Measuring Rate',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Determining Rate of Reaction',
  ),

  QuestionModel(
    question: 'Which of the following would increase the rate of reaction between a metal and an acid?',
    options: [
      'Using a larger piece of metal',
      "Decreasing the acid's concentration",
      'Lowering the temperature',
      "Increasing the acid's concentration",
    ],
    correctIndex: 3,
    feedbackCorrect:
        "Correct. Increasing the acid's concentration increases the frequency of collisions between reacting particles, increasing the rate.",
    feedbackWrong:
        'Increasing concentration raises the rate of reaction. Using a larger (less surface area per mass) metal piece or lowering temperature would slow it down instead.',
    shortLabel: 'Ch7 Factors',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Factors Affecting Rate of Reactions',
  ),

  QuestionModel(
    question:
        'Why does powdered calcium carbonate react faster with acid than a large marble chip of the same mass?',
    options: [
      'Powdered calcium carbonate has a larger total surface area',
      'Powdered calcium carbonate has a different chemical formula',
      'Powdered calcium carbonate is more concentrated',
      'Powdered calcium carbonate has a lower activation energy',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. A larger surface area exposes more particles to the acid at once, increasing the frequency of collisions and the rate of reaction.',
    feedbackWrong:
        'The reaction is faster because powder has a larger total surface area, exposing more particles to collide with acid particles per second.',
    shortLabel: 'Ch7 Surface Area',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Factors Affecting Rate of Reactions',
  ),

  QuestionModel(
    question:
        'Enzymes used in the food industry, such as in cheese and bread making, act as:',
    options: [
      'Reactants that get used up',
      'Biological catalysts',
      'Inhibitors that slow reactions',
      'Products of the reaction',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Enzymes are biological catalysts that speed up reactions in food processing without being consumed.',
    feedbackWrong:
        'Enzymes act as biological catalysts — they speed up reactions without being used up, unlike reactants or products.',
    shortLabel: 'Ch7 Enzymes',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Applications in Daily Life',
  ),

  QuestionModel(
    question: 'According to collision theory, a reaction only occurs when colliding particles:',
    options: [
      'Have the same size',
      'Are moving in the same direction',
      'Collide with sufficient energy and correct orientation',
      'Are of the same chemical element',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Collision theory states that particles must collide with energy equal to or greater than the activation energy, and in the correct orientation, for a reaction to occur.',
    feedbackWrong:
        'An effective collision requires both sufficient energy (at least the activation energy) and the correct orientation — not matching size, direction, or element.',
    shortLabel: 'Ch7 Collision Theory',
    chapter: 'Rate of Reaction',
    chapterNumber: 7,
    subtopic: 'Collision Theory',
  ),

  // ── Chapter 8 additions ──
  QuestionModel(
    question: 'Steel is an alloy made mainly of:',
    options: [
      'Copper and tin',
      'Copper and zinc',
      'Aluminium and copper',
      'Iron and carbon',
    ],
    correctIndex: 3,
    feedbackCorrect:
        'Correct. Steel is an alloy of iron with a small, controlled amount of carbon, which increases its hardness and strength.',
    feedbackWrong:
        'Steel is iron mixed with a small amount of carbon. Copper-tin is bronze, and copper-zinc is brass.',
    shortLabel: 'Ch8 Steel',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Alloy and Its Importance',
  ),

  QuestionModel(
    question: 'Why are alloys generally harder and stronger than pure metals?',
    options: [
      'Different-sized atoms in the alloy disrupt the regular layers, preventing them from sliding easily',
      'Alloys contain fewer free electrons than pure metals',
      'Alloys have larger metallic bonds',
      'Alloys are always lighter than pure metals',
    ],
    correctIndex: 0,
    feedbackCorrect:
        'Correct. The different-sized atoms in an alloy disrupt the orderly layer structure of the pure metal, making the layers harder to slide over each other.',
    feedbackWrong:
        'Alloys are harder because different-sized atoms disrupt the regular arrangement of metal layers, preventing them from sliding as easily as in a pure metal.',
    shortLabel: 'Ch8 Alloy Strength',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Alloy and Its Importance',
  ),

  QuestionModel(
    question: 'Soda-lime glass, the most common type of glass, is made primarily from:',
    options: [
      'Boron oxide and silica',
      'Silica (sand), sodium carbonate, and limestone',
      'Lead oxide and silica',
      'Silica and aluminium oxide only',
    ],
    correctIndex: 1,
    feedbackCorrect:
        'Correct. Soda-lime glass is made by heating silica (sand) with sodium carbonate and limestone.',
    feedbackWrong:
        'Soda-lime glass comes from silica, sodium carbonate, and limestone. Borosilicate glass contains boron oxide, and lead glass (crystal) contains lead oxide.',
    shortLabel: 'Ch8 Glass',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composition of Glass and Its Uses',
  ),

  QuestionModel(
    question: 'Ceramics are generally known for being:',
    options: [
      'Good conductors of electricity',
      'Soft and easily bent',
      'Hard, brittle, and resistant to high temperatures',
      'Highly flexible and elastic',
    ],
    correctIndex: 2,
    feedbackCorrect:
        'Correct. Ceramics are hard, brittle materials with high resistance to heat and chemical attack, making them useful for insulators and cookware.',
    feedbackWrong:
        'Ceramics are hard, brittle, and heat-resistant — not good electrical conductors or flexible materials.',
    shortLabel: 'Ch8 Ceramics',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composition of Ceramics and Its Uses',
  ),

  QuestionModel(
    question: 'Reinforced concrete is an example of a composite material because it combines:',
    options: [
      'Two different metals only',
      'Glass and ceramic',
      'Two types of polymer',
      'Concrete (good under compression) and steel rods (good under tension)',
    ],
    correctIndex: 3,
    feedbackCorrect:
        "Correct. Reinforced concrete combines concrete's compressive strength with steel's tensile strength, giving properties neither material has alone.",
    feedbackWrong:
        "Reinforced concrete combines concrete (strong under compression) with steel rods (strong under tension) — a composite material with combined properties.",
    shortLabel: 'Ch8 Composite',
    chapter: 'Manufactured Substances in Industry',
    chapterNumber: 8,
    subtopic: 'Composite Materials and Its Importance',
  ),
];

List<QuestionModel> hardcodedQuestionsForChapter(
  int chapterNumber, {
  int count = 5,
}) {
  final questions = kHardcodedQuestions
      .where((question) => question.chapterNumber == chapterNumber)
      .toList()
    ..shuffle();
  return questions.take(count).toList();
}

List<QuestionModel> hardcodedDiagnosticQuestions() {
  const distribution = {1: 2, 2: 4, 3: 4, 4: 4, 5: 5, 6: 10, 7: 5, 8: 3};
  return distribution.entries
      .expand(
        (entry) => hardcodedQuestionsForChapter(entry.key, count: entry.value),
      )
      .toList();
}
