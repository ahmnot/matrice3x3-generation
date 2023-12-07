import JSZip from "libraries/jszip.min.js";
import saveAs from "libraries/FileSaver.js";

// Définition : un "bloc" est une matrice 3x3 constituée de 0 ou de 1. 
// Pour visualiser ces carrés, on convient que :
// 0=petit carré noir, et 1=petit carré blanc.
// L'objectif de ce code est de générer l'exhaustivité de ces blocs et les classer.
// Le format des blocs : [[1,1,1],[1,1,0],[0,0,0]].
// let tousLesBlocs = [[[1,1,1],[1,1,0],[0,0,0]], [[1,1,1],[1,0,1],[0,0,0]], ...];



/**
 * DEFINITION DES CARRES EN COURS
 * Définition : un "carré" est un objet, 
 * qui est la base constitutive d'un bloc. 
 * Un carré est lui-même constitué :
 * - D'un booléen, true si le carré est blanc,
 *  false si le carré est noir. 
 *  Si le carré est blanc, on dit qu'il est "accessible".
 *  Si le carré est noir, on dit qu'il est "inaccessible".
 * - d'une liste de 4 éléments, constituée de 0 ou de 1. 
 *  Cette liste représente les 4 bords du carré, dans
 *  l'ordre : gauche, haut, droite, bas.
 *  
 *  
 * 
 * 
 * 
 * 
 * 
 * 
 */

let tousLesBinaires = [];
let tousLesBlocs = [];

/**
 * Utilitaire de transposition d'une matrice
 * @param {*} matrix 
 * @returns 
 */
function transposeBloc(matrix) {
  const rows = matrix.length, cols = matrix[0].length;
  const grid = [];
  for (let j = 0; j < cols; j++) {
    grid[j] = Array(rows);
  }
  for (let i = 0; i < rows; i++) {
    for (let j = 0; j < cols; j++) {
      grid[j][i] = matrix[i][j];
    }
  }
  return grid;
}

/**
 * Utilitaire de rotation à 90° d'une matrice
 * @param {*} matrix 
 * @returns 
 */
function rotateBlocPlus90(matrix) {
  return matrix[0].map((val, index) => matrix.map(row => row[index]).reverse());
}

/**
 * Utilitaire de rotation à -90° d'une matrice
 * @param {*} matrix 
 * @returns 
 */
function rotateBlocMinus90(matrix) {
  return matrix[0].map((val, index) => matrix.map(row => row[row.length - 1 - index]));
}

/**
 * Fonction qui change les 0 en 1 et les 1 en 0 de la matrice en paramètre.
 * @param {*} matrix 
 * @returns 
 */
function oppositionnerMatrice(matrix) {
  return matrix.map(row => row.map(element => (element === 0 ? 1 : 0)));
}

/**
 * Génère la symétrie horizontale d'une matrice.
 * @param {*} matrix 
 * @returns 
 */
function symetriserHorizontalement(matrix) {
  return matrix.slice().reverse();
}

/**
 * Génère la symétrie verticale d'une matrice.
 * @param {*} matrix 
 * @returns 
 */
function symetriserVerticalement(matrix) {
  return matrix.map(row => row.slice().reverse());
}

/**
 * Utilitaire qui compare deux matrices pour vérifier si elles sont identiques.
 * @param {*} matrix1 
 * @param {*} matrix2 
 * @returns 
 */
function areMatricesEqual(matrix1, matrix2) {
  return matrix1.every((row, rowIndex) => row.every((val, colIndex) => val === matrix2[rowIndex][colIndex]));
}

/**
 * Compare deux lignes (tableaux) pour vérifier si elles sont identiques.
 * @param {*} ligne1 
 * @param {*} ligne2 
 * @returns 
 */
function areLignesEgales(ligne1, ligne2) {
  return ligne1.length === ligne2.length && ligne1.every((val, index) => val === ligne2[index]);
}

/**
 * Utilitaire qui vérifie si un bloc est une rotation d'un autre.
 * @param {*} bloc 
 * @param {*} autreBloc 
 * @returns 
 */
function estRotationDe(bloc, autreBloc) {
  let rotation = autreBloc;
  for (let i = 0; i < 4; i++) { // 4 rotations possibles : 0°, 90°, 180°, 270°
    if (areMatricesEqual(bloc, rotation)) {
      return true;
    }
    rotation = rotateBlocPlus90(rotation);
  }
  return false;
}

/**
 * Vérifie si un bloc est équivalent par rotation à un bloc dans une liste donnée.
 * @param {*} bloc 
 * @param {*} liste 
 * @returns 
 */
function estEquivalentParRotation(bloc, liste) {
  return liste.some(autreBloc => estRotationDe(bloc, autreBloc));
}

/**
 * Filtrer les blocs pour ne conserver qu'un exemplaire unique par classe d'équivalence de rotation.
 */
function filtrerBlocsParClasseDeRotation(listeBlocs = []) {
  let listeResultat = [];

  listeBlocs.forEach(bloc => {
    if (!estEquivalentParRotation(bloc, listeResultat)) {
      listeResultat.push(bloc);
    }
  });

  return listeResultat;
}

/**
 * Vérifie si une matrice a une symétrie axiale horizontale.
 * @param {*} matrix 
 * @returns 
 */
function aSymetrieHorizontale(matrix) {
  for (let i = 0; i < Math.floor(matrix.length / 2); i++) {
    if (!areLignesEgales(matrix[i], matrix[matrix.length - 1 - i])) {
      return false;
    }
  }
  return true;
}

/**
 * Vérifie si une matrice a une symétrie axiale verticale.
 * @param {*} matrix 
 * @returns 
 */
function aSymetrieVerticale(matrix) {
  for (let i = 0; i < matrix.length; i++) {
    for (let j = 0; j < matrix[i].length / 2; j++) {
      if (matrix[i][j] !== matrix[i][matrix[i].length - 1 - j]) {
        return false;
      }
    }
  }
  return true;
}

/**
 * Vérifie si 2 blocs sont équivalents par symétrie axiale, en prenant en compte les rotations.
 * @param {*} bloc1 
 * @param {*} bloc2 
 * @returns 
 */
function sontEquivalentParSymetrieRotation(bloc1, bloc2) {
  let rotation = bloc2;
  for (let i = 0; i < 4; i++) {
    if (areMatricesEqual(bloc1, symetriserHorizontalement(rotation)) || 
        areMatricesEqual(bloc1, symetriserVerticalement(rotation))) {
      return true;
    }
    rotation = rotateBlocPlus90(rotation);
  }
  return false;
}

/**
 * Filtrer les blocs pour ne conserver qu'un exemplaire unique par "classe d'équivalence de symétrie-rotation".
 */
function filtrerBlocsParClasseDeSymetrieRotation(listeBlocs = []) {
  let listeResultat = [];
  
  listeBlocs.forEach(bloc => {
    let estUnique = true;
    for (let autreBloc of listeResultat) {
      if (sontEquivalentParSymetrieRotation(bloc, autreBloc)) {
        estUnique = false;
        break;
      }
    }
    if (estUnique) {
      listeResultat.push(bloc);
    }
  });

  return listeResultat;
}

/**
 * Vérifie si les carrés blancs (=1) sont connectés entre eux 
 * dans le bloc passé en paramètre.
 * @param {*} matrice 
 * @returns 
 */
function areOnesConnected(matrice) {
  // Directions pour explorer les voisins : bas, haut, droite, gauche
  const directions = [[1, 0], [-1, 0], [0, 1], [0, -1]];
  const taille = matrice.length; // Supposer une matrice carrée pour la simplicité

  // Fonction récursive pour explorer la continuité à partir d'une case donnée
  function explorerContinuite(i, j, visite) {
    // Vérifier si la case est hors limites ou déjà visitée ou contient un 0
    if (i < 0 || i >= taille || j < 0 || j >= taille || visite[i][j] || matrice[i][j] === 0) {
      return;
    }

    // Marquer la case actuelle comme visitée
    visite[i][j] = true;

    // Itérer sur chaque direction et explorer récursivement
    for (let [di, dj] of directions) {
      explorerContinuite(i + di, j + dj, visite);
    }
  }

  // Initialiser un tableau pour marquer les cases visitées
  let visite = Array.from({ length: taille }, () => Array(taille).fill(false));
  let premierUnTrouve = false; // Pour vérifier si au moins un "1" a été trouvé

  // Parcourir chaque cellule de la matrice
  for (let i = 0; i < taille; i++) {
    for (let j = 0; j < taille; j++) {
      // Si on trouve un "1"
      if (matrice[i][j] === 1) {
        // Si c'est le premier "1", explorer à partir de cette case
        if (!premierUnTrouve) {
          explorerContinuite(i, j, visite);
          premierUnTrouve = true;
        }
        // Si ce n'est pas le premier "1", vérifier s'il a été visité
        else if (!visite[i][j]) {
          return false; // Retourner false si un "1" non connecté est trouvé
        }
      }
    }
  }

  // Retourner true si tous les "1" sont connectés (ou si aucun "1" n'a été trouvé)
  return premierUnTrouve;
}

// Vérifie si le bloc répond aux critères du pattern 0
function verifierPattern0(bloc) {
  // Pattern 0: Carrés blancs adjacents directement
  return bloc.flat().filter(val => val === 1).length === 1 ||
    bloc.some((ligne, i) =>
      ligne.some((val, j) =>
        val === 1 && (
          // Vérifier les carrés adjacents horizontalement et verticalement
          (bloc[i][j + 1] === 1 || bloc[i][j - 1] === 1 || (bloc[i + 1] && bloc[i + 1][j] === 1) || (bloc[i - 1] && bloc[i - 1][j] === 1))
        )
      )
    );
}

// Vérifie si le bloc répond aux critères du pattern 1
function verifierPattern1(bloc) {
  // Pattern 1: Carrés blancs adjacents en diagonale sans sauter par-dessus un carré noir
  return bloc.some((ligne, i) =>
    ligne.some((val, j) =>
      val === 1 && (
        ((bloc[i + 1] && bloc[i + 1][j + 1] === 1) || (bloc[i - 1] && bloc[i - 1][j - 1] === 1) ||
          (bloc[i + 1] && bloc[i + 1][j - 1] === 1) || (bloc[i - 1] && bloc[i - 1][j + 1] === 1))
      )
    )
  );
}

// Vérifie si le bloc répond aux critères du pattern 2
function verifierPattern2(bloc) {
  // Pattern 2: Carrés blancs séparés par un carré sur la même ligne ou colonne
  return bloc.some((ligne, i) =>
    ligne.some((val, j) =>
      val === 1 && (
        (bloc[i][j + 2] === 1) ||
        (bloc[i][j - 2] === 1) ||
        (bloc[i + 2] && bloc[i + 2][j] === 1) ||
        (bloc[i - 2] && bloc[i - 2][j] === 1)
      )
    ));
}


// Vérifie si le bloc répond aux critères du pattern 3
function verifierPattern3(bloc) {
  let positions = [];

  // Trouver les positions de tous les "1" dans la matrice
  for (let i = 0; i < bloc.length; i++) {
    for (let j = 0; j < bloc[i].length; j++) {
      if (bloc[i][j] === 1) {
        positions.push({ i, j });
      }
    }
  }

  // Vérifier les conditions pour chaque paire de "1"
  for (let a = 0; a < positions.length; a++) {
    for (let b = a + 1; b < positions.length; b++) {
      let posA = positions[a];
      let posB = positions[b];

      // Vérifier qu'ils ne sont pas sur la même ligne ou la même colonne et qu'ils ne sont pas dans les coins opposés
      if (posA.i !== posB.i && posA.j !== posB.j && !(posA.i + posB.i === 2 && posA.j + posB.j === 2)) {
        // Vérifier s'ils sont sur des lignes ou des colonnes opposées
        if ((posA.i === 0 && posB.i === 2) || (posA.i === 2 && posB.i === 0) ||
          (posA.j === 0 && posB.j === 2) || (posA.j === 2 && posB.j === 0)) {
          return true;
        }
      }
    }
  }

  return false;
}

// Vérifie si le bloc répond aux critères du pattern 4
function verifierPattern4(bloc) {
  // Pattern 4: Carrés blancs dans des coins opposés
  // Vérifier les coins opposés sur les deux diagonales
  let coinHautGauche = bloc[0][0];
  let coinBasDroit = bloc[2][2];
  let coinHautDroit = bloc[0][2];
  let coinBasGauche = bloc[2][0];

  // Vérifier si les coins haut gauche et bas droit sont tous les deux "1"
  let diagonale1 = (coinHautGauche === 1 && coinBasDroit === 1);
  // Vérifier si les coins haut droit et bas gauche sont tous les deux "1"
  let diagonale2 = (coinHautDroit === 1 && coinBasGauche === 1);

  return diagonale1 || diagonale2;
}

function verifierPatternm1(bloc) {
  return JSON.stringify(bloc) === JSON.stringify([
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
  ]);
}


// Exemples d'utilisation des fonctions de vérification
let blocExemple = [
  [1, 0, 0],
  [1, 1, 1],
  [0, 0, 1]
];
afficherBlocDansConsole(blocExemple);

console.log("1 connectés = " + areOnesConnected(blocExemple));

console.log("pattern 0 = " + verifierPattern0(blocExemple));
console.log("pattern 1 = " + verifierPattern1(blocExemple));
console.log("pattern 2 = " + verifierPattern2(blocExemple));
console.log("pattern 3 = " + verifierPattern3(blocExemple));
console.log("pattern 4 = " + verifierPattern4(blocExemple));
console.log("pattern -1 = " + verifierPatternm1(blocExemple));


/**
 * Utilitaire d'affichage d'une matrice dans la console
 * @param {*} bloc 
 */
function afficherBlocDansConsole(bloc) {
  console.log("[");
  for (let i = 0; i < bloc.length; i++) {
    console.log("  [" + bloc[i].join(",") + "]");
  }
  console.log("]");
}

/**
 * Utilitaire d'affichage d'une liste de matrices dans la console
 * @param {*} listeBlocs 
 */
function afficherListeBlocsDansConsole(listeBlocs) {
  for (let i = 0; i < listeBlocs.length; i++) {
    afficherBlocDansConsole(listeBlocs[i]);
    if (i < listeBlocs.length - 1) {
      console.log(""); // Ajout une ligne vide entre les blocs
    }
  }
}

/**
 * Fonction qui génère tous les binaires, de "000000000" à "111111111" (de 0 à 511).
 */
function genererBinaires9Chiffres() {
  let binaires = [];
  for (let i = 0; i < 512; i++) { // 2^9 = 512
    let binaire = i.toString(2); // Convertir le nombre en binaire
    while (binaire.length < 9) {
      binaire = "0" + binaire; // Ajouter des zéros au début pour avoir 9 chiffres
    }
    binaires.push(binaire);
  }
  return binaires;
}

tousLesBinaires = genererBinaires9Chiffres();

/**
 * Sert à compter le nombre de "1" dans un binaire.
 * @param {*} binaire 
 * @returns 
 */
function compterUns(binaire) {
  return binaire.split('').filter(caractere => caractere === '1').length;
}

// Tri de la liste selon le nombre de "1"
tousLesBinaires.sort((a, b) => compterUns(a) - compterUns(b));

/**
 * Sert à randomiser l'ordre des éléments d'une liste.
 * @param {*} array 
 */
function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
  }
}

/**
 * Fonction qui renvoie une sous-liste de binaires, à partir de listeBinaires,
 * qui ont une quantité nombreUns de "1" dans leurs chaînes de caractère
 * @param {*} listeBinaires 
 * @param {*} nombreUns 
 * @returns 
 */
function filtrerParNombreDeUns(listeBinaires, nombreUns) {
  return listeBinaires.filter(binaire => 
    binaire.split('').filter(caractere => caractere === '1').length === nombreUns
  );
}

/**
 * Sert à transformer une liste de binaires en une liste de blocs.
 * @param {*} listeBinaires 
 * @returns 
 */
function genererLesBlocs(listeBinaires) {
  let blocsResultat = [];
  listeBinaires.forEach(unBinaire => {
    blocsResultat.push(genererBloc(unBinaire));
  });
  return blocsResultat;
}

/**
 * Sert à filtrer les "blocs continus" dans une liste de blocs.
 * @param {*} listeBlocs 
 * @returns 
 */
function filtrerBlocsContinus(listeBlocs){
  let blocsResultat = [];
  listeBlocs.forEach(unBloc => {
    if (areOnesConnected(unBloc)) {
      blocsResultat.push(unBloc);
    }
  });
  return blocsResultat;
}

/**
 * Sert à filtrer les "blocs brisés" dans une liste de blocs.
 * @param {*} listeBlocs 
 * @returns 
 */
function filtrerBlocsBrises(listeBlocs){
  let blocsResultat = [];
  listeBlocs.forEach(unBloc => {
    if (!areOnesConnected(unBloc)) {
      blocsResultat.push(unBloc);
    }
  });
  return blocsResultat;
}

/**
 * Fonction qui génère un bloc à partir d'un nombre binaire
 * @param {*} binaire un binaire
 * @returns 
 */
function genererBloc(binaire) {
  //Ajout préalable de 0 à la fin des binaires si besoin
  while (binaire.length != 9) {
    binaire += "0";
  }
  let bloc = [];
  let compteur = 0;
  for (let i = 0; i < 3; i++) {
    let row = [];
    for (let j = 0; j < 3; j++) {
      row.push(parseInt(binaire.charAt(compteur)));
      compteur++;
    }
    bloc.push(row);
  }
  return bloc;
}

let nombreCarresBlancs = 5;
// Appel de la fonction avec n=9 (nombre de chiffres) et k=5 (nombre de "1")
tousLesBlocs = genererLesBlocs(tousLesBinaires);
let blocsContinus = filtrerBlocsContinus(tousLesBlocs);
let blocsBrises = filtrerBlocsBrises(tousLesBlocs);
// Pour des raisons d'affichage, je reverse les listes :
tousLesBlocs.reverse();
blocsContinus.reverse();
blocsBrises.reverse();

let blocsAffiches = [];

let scaling = 12;
let rownumber = 9;
let elementsPerRow = Math.ceil(tousLesBlocs.length / rownumber);
let squareSize = 3; // Taille du carré (3x3, 4x4, etc.)
let verticalLineWidth = 1; // Largeur de la ligne verticale
let horizontalLineWidth = 1;

let canvasWidth = elementsPerRow * (squareSize * scaling + verticalLineWidth) - verticalLineWidth;
let canvasHeight = rownumber * squareSize * scaling;
let decalageHorizontal = 0;

let radioChoixDuMode;

let tutoTexte;
let sliderNombreCarres;
let sliderNombreCarresLegende;


let checkboxAfficherTout;
let checkboxRotations;
let checkboxSymetries;
let radioTypeBlocs;
let radioTypeBlocsLegende;
let legendeFiltres;
let checkboxes = [];
let checkboxRandomiser;
let stringPatternChecked = "";
let nombreBlocs;
let exportButton;

let positionIHMx = 300;
let positionIHMy = 500;

let minWidth = 1000; // Largeur minimale du canvas
let minHeight = 1500; // Hauteur minimale du canvas

let totalWidth = squareSize * scaling + verticalLineWidth;
let gridStartX = 0; // À mettre à jour si la grille ne commence pas à x=0
let gridStartY = 0; // À mettre à jour si la grille ne commence pas à y=0

let gridEndX = gridStartX + elementsPerRow * totalWidth;
let gridEndY = gridStartY + rownumber * (squareSize * scaling);

let isMenuBlocsShown = false;

let couleurBackground = 15;

function initializeMenuBlocs() {
  tutoTexte = createP();
  tutoTexte.position(positionIHMx + 25, positionIHMy - 20);
  tutoTexte.html(`Cliquez sur un bloc pour l'exporter.`);
  sliderNombreCarres = createSlider(0, 9, nombreCarresBlancs, 1);
  sliderNombreCarres.position(positionIHMx + 20, positionIHMy + 50);
  sliderNombreCarres.style('width', '200px');
  sliderNombreCarresLegende = createP(`${sliderNombreCarres.value()}`);
  sliderNombreCarresLegende.position(positionIHMx + 50, positionIHMy + 20);

  checkboxAfficherTout = createCheckbox('Afficher tous les blocs', false);
  checkboxAfficherTout.position(positionIHMx + 225, positionIHMy + 40);

  checkboxRotations = createCheckbox('Enlever rotations', false);
  checkboxRotations.position(positionIHMx + 20, positionIHMy + 80);

  checkboxSymetries = createCheckbox('Enlever symétries (dont symétries-rotations)', false);
  checkboxSymetries.position(positionIHMx + 140, positionIHMy + 80);

  radioTypeBlocsLegende = createP();
  radioTypeBlocsLegende.position(positionIHMx + 50, positionIHMy + 70 + 30);
  radioTypeBlocsLegende.html(`Type de blocs affichés`);
  radioTypeBlocs = createRadio("TypeBlocs");
  radioTypeBlocs.option('Tous');
  radioTypeBlocs.option('Continus');
  radioTypeBlocs.option('Brisés');
  radioTypeBlocs.position(positionIHMx + 20, positionIHMy + 100 + 30);
  radioTypeBlocs.selected('Tous');

  legendeFiltres = createP();
  legendeFiltres.position(positionIHMx + 50, positionIHMy + 175);
  legendeFiltres.html(`Application de filtres`);

  checkboxes[0] = createCheckbox('Pattern 0', false);
  checkboxes[1] = createCheckbox('Pattern 1', false);
  checkboxes[2] = createCheckbox('Pattern 2', false);
  checkboxes[3] = createCheckbox('Pattern 3', false);
  checkboxes[4] = createCheckbox('Pattern 4', false);
  checkboxes[5] = createCheckbox('Pattern -1', false);
  checkboxes[0].position(positionIHMx + 20, positionIHMy + 175 + 30);
  checkboxes[1].position(positionIHMx + 20, positionIHMy + 175 + 50);
  checkboxes[2].position(positionIHMx + 20, positionIHMy + 175 + 70);
  checkboxes[3].position(positionIHMx + 20, positionIHMy + 175 + 90);
  checkboxes[4].position(positionIHMx + 20, positionIHMy + 175 + 110);
  checkboxes[5].position(positionIHMx + 20, positionIHMy + 175 + 130);
  
  checkboxRandomiser = createCheckbox("Randomiser ordre des blocs", false);
  checkboxRandomiser.position(positionIHMx + 230, positionIHMy + 250);

  nombreBlocs = createP();
  nombreBlocs.position(positionIHMx + 40, positionIHMy + 330);
  nombreBlocs.html(`Nombre de blocs affichés : `);

  exportButton = createButton('Exporter tous les blocs affichés');
  exportButton.position(positionIHMx + 30, positionIHMy + 365);
  exportButton.mousePressed(exportAllBlocks);
  isMenuBlocsShown = true;
}

function preload() {
  exempleBlocContinu = loadImage("blocs-6_19.png");
  exempleBlocBrise = loadImage("blocs-5_09.png");
  exemplePattern01 = loadImage("blocs-2_22.png");
  exemplePattern02 = loadImage("bloc-1-3.png");
  exemplePattern1 = loadImage("blocs-2_04.png");
  exemplePattern2 = loadImage("blocs-2_23.png");
  exemplePattern3 = loadImage("blocs-2_05.png");
  exemplePattern4 = loadImage("blocs-2_08.png");
  exemplePatternm11 = loadImage("bloc-0.png");
}

function setup() {
  let choixDuMode = createP();
  choixDuMode.position(positionIHMx + 25, positionIHMy - 100);
  choixDuMode.html(`Sélection du mode`);
  radioChoixDuMode = createRadio("ChoixDuMode");
  radioChoixDuMode.option('Génération exhaustive de blocs');
  radioChoixDuMode.option('Génération de labyrinthes');
  radioChoixDuMode.position(positionIHMx + 20, positionIHMy - 70);
  radioChoixDuMode.selected('Génération exhaustive de blocs');

  if (radioChoixDuMode.value() === "Génération exhaustive de blocs") {
    initializeMenuBlocs();  
  }

  canvasWidth = elementsPerRow * (squareSize * scaling + verticalLineWidth) - verticalLineWidth;
  canvasHeight = rownumber * squareSize * scaling;

  canvasWidth = max(canvasWidth, minWidth);
  canvasHeight = max(canvasHeight, minHeight);

  createCanvas(canvasWidth, canvasHeight);
  background(couleurBackground);
}

function draw() {
  if (radioChoixDuMode.value() === "Génération exhaustive de blocs") {
    if (!isMenuBlocsShown) {
      showMenuBlocs();
    }
    else if (isMenuBlocsShown) {
      nombreCarresBlancs = sliderNombreCarres.value();
      sliderNombreCarresLegende.html(`Carrés blancs par bloc : ${nombreCarresBlancs}`);
      // Réinitialisation des listes
      tousLesBlocs = [];
      blocsContinus = [];
      blocsBrises = [];
  
      // Génération des nouveaux blocs
      if (checkboxAfficherTout.checked()) {
        tousLesBlocs = genererLesBlocs(tousLesBinaires);
        sliderNombreCarres.elt.disabled = true;
        sliderNombreCarresLegende.html(`Carrés blancs par bloc : tous`);
      } else {
        tousLesBlocs = genererLesBlocs(filtrerParNombreDeUns(tousLesBinaires, nombreCarresBlancs));
        sliderNombreCarres.elt.disabled = false;
      }

      blocsContinus = filtrerBlocsContinus(tousLesBlocs);
      blocsBrises = filtrerBlocsBrises(tousLesBlocs);
  
      tousLesBlocs.reverse();
      blocsContinus.reverse();
      blocsBrises.reverse();
  
      if (checkboxRotations.checked()) {
        tousLesBlocs = filtrerBlocsParClasseDeRotation(tousLesBlocs);
        blocsContinus = filtrerBlocsParClasseDeRotation(blocsContinus);
        blocsBrises = filtrerBlocsParClasseDeRotation(blocsBrises);
      }
  
      if (checkboxSymetries.checked()) {
        tousLesBlocs = filtrerBlocsParClasseDeSymetrieRotation(tousLesBlocs);
        blocsContinus = filtrerBlocsParClasseDeSymetrieRotation(blocsContinus);
        blocsBrises = filtrerBlocsParClasseDeSymetrieRotation(blocsBrises);
      }
  
      // Filtre sur le type de blocs affichés
      switch (radioTypeBlocs.value()) {
        case 'Tous':
          blocsAffiches = tousLesBlocs;
          break;
        case 'Continus':
          blocsAffiches = blocsContinus;
          break;
        case 'Brisés':
          blocsAffiches = blocsBrises;
          break;
  
        default:
          break;
      }
  
      // Filtre sur les différents patterns présents dans les blocs
      if (checkboxes[0].checked()) {
        blocsAffiches = blocsAffiches.filter(verifierPattern0);
      }
      if (checkboxes[1].checked()) {
        blocsAffiches = blocsAffiches.filter(verifierPattern1);
      }
      if (checkboxes[2].checked()) {
        blocsAffiches = blocsAffiches.filter(verifierPattern2);
      }
      if (checkboxes[3].checked()) {
        blocsAffiches = blocsAffiches.filter(verifierPattern3);
      }
      if (checkboxes[4].checked()) {
        blocsAffiches = blocsAffiches.filter(verifierPattern4);
      }
      if (checkboxes[5].checked()) {
        blocsAffiches = blocsAffiches.filter(verifierPatternm1);
      }
      
      if (checkboxRandomiser.checked()) {
        shuffleArray(blocsAffiches);
      }
  
      nombreBlocs.html(`Nombre de blocs affichés : ${blocsAffiches.length}`);
  
      elementsPerRow = Math.ceil(blocsAffiches.length / rownumber);
      canvasWidth = elementsPerRow * (squareSize * scaling + verticalLineWidth) - verticalLineWidth;
      canvasHeight = rownumber * squareSize * scaling;
      canvasWidth = max(canvasWidth, minWidth);
      canvasHeight = max(canvasHeight, minHeight);
  
      resizeCanvas(canvasWidth, canvasHeight);
  
      // Mise à jour de l'affichage
      background(couleurBackground); // Nettoie le canvas avant de redessiner
      image(exempleBlocContinu, 383, positionIHMy + 130);
      image(exempleBlocBrise, 447, positionIHMy + 130);
      image(exemplePattern01, 383,  positionIHMy + 175 + 12);
      image(exemplePattern02, 403,  positionIHMy + 175 +12);
      image(exemplePattern1, 383,  positionIHMy + 175 +32);
      image(exemplePattern2, 383,  positionIHMy + 175 +52);
      image(exemplePattern3, 383,  positionIHMy + 175 +72);
      image(exemplePattern4, 383,  positionIHMy + 175 +92);
      image(exemplePatternm11, 383,  positionIHMy + 175 +112);
  
      for (let l = 0; l < rownumber; l++) {
        for (let k = 0; k < elementsPerRow; k++) {
          let index = l * elementsPerRow + k;
          if (index < blocsAffiches.length) {
            let unBloc = blocsAffiches[index];
            for (let i = 0; i < squareSize; i++) {
              for (let j = 0; j < squareSize; j++) {
                if (unBloc[i][j] === 1) {
                  fill(255); // Couleur du carré
                  noStroke();
                  square(
                    j * scaling + decalageHorizontal,
                    i * scaling + l * squareSize * scaling,
                    scaling
                  );
                }
              }
            }
            decalageHorizontal += squareSize * scaling + verticalLineWidth;
          }
        }
        decalageHorizontal = 0; // Réinitialiser le décalage pour chaque ligne
        // Dessiner la ligne horizontale après chaque ligne de blocs
        if (l < rownumber - 1) { // Pas de ligne après la dernière rangée
          stroke(couleurBackground); // Couleur de la ligne
          strokeWeight(horizontalLineWidth);
          line(0, (l + 1) * squareSize * scaling, canvasWidth, (l + 1) * squareSize * scaling);
        }
      }
  
      drawHoverSquare();
    }
  } else {
      background(couleurBackground);
      hideMenuBlocs();  
  }
}

function showMenuBlocs() {
  tutoTexte.show();
  sliderNombreCarres.show();
  sliderNombreCarresLegende.show();

  checkboxAfficherTout.show();
  checkboxRotations.show();
  checkboxSymetries.show();
  
  radioTypeBlocs.show();
  radioTypeBlocsLegende.show();
  legendeFiltres.show();
  checkboxes[0].show();
  checkboxes[1].show();
  checkboxes[2].show();
  checkboxes[3].show();
  checkboxes[4].show();
  checkboxes[5].show();

  nombreBlocs.show();

  exportButton.show();
  isMenuBlocsShown = true;
}

function hideMenuBlocs() {
  tutoTexte.hide();
  sliderNombreCarres.hide();
  sliderNombreCarresLegende.hide();

  checkboxAfficherTout.hide();
  checkboxRotations.hide();
  checkboxSymetries.hide();
  
  radioTypeBlocs.hide();
  radioTypeBlocsLegende.hide();
  legendeFiltres.hide();
  checkboxes[0].hide();
  checkboxes[1].hide();
  checkboxes[2].hide();
  checkboxes[3].hide();
  checkboxes[4].hide();
  checkboxes[5].hide();

  nombreBlocs.hide();

  exportButton.hide();
  isMenuBlocsShown = false;
}

/**
 * Fonction qui sert à dessiner le carré rouge de survol de la grille
 */
function drawHoverSquare() {
  let gridX = Math.floor(mouseX / totalWidth);
  let gridY = Math.floor(mouseY / (squareSize * scaling));
  // Vérifiez si la souris est à l'intérieur du canvas
  if (mouseX >= gridStartX && mouseX < gridEndX && mouseY >= gridStartY && mouseY < gridEndY) {
    stroke(255, 0, 0); // Couleur de la bordure du carré de survol
    noFill();
    strokeWeight(2); // Épaisseur de la bordure
    square(gridX * totalWidth, gridY * squareSize * scaling, squareSize * scaling);
  }
}

/**
 * Gère l'export d'un bloc au clic.
 */
function mouseClicked() {
  let gridX = Math.floor(mouseX / totalWidth);
  let gridY = Math.floor(mouseY / (squareSize * scaling));
  // Vérifie si le clic est à l'intérieur de la grille
  if (mouseX >= gridStartX && mouseX < gridEndX && mouseY >= gridStartY && mouseY < gridEndY) {
    // Obtient l'index du bloc sur lequel l'utilisateur a cliqué
    let index = gridY * elementsPerRow + gridX;
    if (index < blocsAffiches.length) {
      let bloc = blocsAffiches[index];

      // Crée un graphique pour dessiner le bloc
      let pg = createGraphics(squareSize * scaling, squareSize * scaling);
      pg.background(0);
      pg.noFill();

      // Dessine le bloc sur le graphique
      for (let i = 0; i < squareSize; i++) {
        for (let j = 0; j < squareSize; j++) {
          if (bloc[i][j] === 1) {
            pg.fill(255);
            pg.noStroke();
            pg.square(j * scaling, i * scaling, scaling);
          }
        }
      }

      // Enregistre le graphique en tant que fichier PNG
      save(pg, `bloc-${sliderNombreCarres.value()}-${index}.png`);
    }
  }
}

function exportAllBlocks() {
  let zip = new JSZip();

  stringPatternChecked = "";

  for (let i = 0; i < checkboxes.length; i++) {
    if (checkboxes[i].checked()) {
      if (i != 5) {
        stringPatternChecked += "-p" + i;
      } else {
        stringPatternChecked += "-pm1";
      }
    }
  }

  blocsAffiches.forEach((bloc, index) => {
    let pg = createGraphics(squareSize * scaling, squareSize * scaling);
    pg.background(0);
    pg.noFill();

    for (let i = 0; i < squareSize; i++) {
      for (let j = 0; j < squareSize; j++) {
        if (bloc[i][j] === 1) {
          pg.fill(255);
          pg.noStroke();
          pg.square(j * scaling, i * scaling, scaling);
        }
      }
    }
    // Ajoutez le PNG au ZIP
    pg.canvas.toBlob(function (blob) {
      zip.file(`bloc-${sliderNombreCarres.value()}-${index}.png`, blob);

      // Vérifiez si c'est le dernier bloc à ajouter
      if (index === blocsAffiches.length - 1) {
        zip.generateAsync({ type: "blob" }).then(function (content) {
          //saveAs vient de FileSaver.js
          saveAs(content, `blocs-${sliderNombreCarres.value()}${stringPatternChecked}.zip`);
        });
      }
    });
  });
}