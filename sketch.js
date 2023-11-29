// Définition : un "bloc" est une matrice 3x3 constituée de 0 ou de 1. 
// Pour visualiser ces carrés, on convient que :
// 0=petit carré noir, et 1=petit carré blanc.
// L'objectif de ce code est de générer l'exhaustivité de ces blocs et les classer.
// Le format des blocs : [[1,1,1],[1,1,0],[0,0,0]].
// let tousLesBlocs = [[[1,1,1],[1,1,0],[0,0,0]], [[1,1,1],[1,0,1],[0,0,0]], ...];
let tousLesBlocs = [];
let blocsContinus = [];
let blocsBrises = [];

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
  return matrix[0].map((val, index) => matrix.map(row => row[row.length-1-index]));
}

function oppositeBloc(matrix) {
  return matrix.map(row => row.map(element => (element === 0 ? 1 : 0)));
}

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

// Vérifie si le bloc répond aux critères du niveau 0
function verifierNiveau0(bloc) {
  // Niveau 1: Carrés blancs adjacents directement ou en diagonale sans sauter par-dessus un carré noir
  return bloc.some((ligne, i) =>
    ligne.some((val, j) =>
      val === 1 && (
        // Vérifier les carrés adjacents horizontalement et verticalement
        (bloc[i][j + 1] === 1 || bloc[i][j - 1] === 1 || (bloc[i + 1] && bloc[i + 1][j] === 1) || (bloc[i - 1] && bloc[i - 1][j] === 1))
      )
  )
  );
}

// Vérifie si le bloc répond aux critères du niveau 1
function verifierNiveau1(bloc) {
  // Niveau 1: Carrés blancs adjacents directement ou en diagonale sans sauter par-dessus un carré noir
  return bloc.some((ligne, i) =>
    ligne.some((val, j) =>
      val === 1 && (
        ((bloc[i + 1] && bloc[i + 1][j + 1] === 1) || (bloc[i - 1] && bloc[i - 1][j - 1] === 1) ||
         (bloc[i + 1] && bloc[i + 1][j - 1] === 1) || (bloc[i - 1] && bloc[i - 1][j + 1] === 1))
      )
  )
  );
}

// Vérifie si le bloc répond aux critères du niveau 2
function verifierNiveau2(bloc) {
  // Niveau 2: Carrés blancs séparés par un seul carré noir sur la même ligne ou colonne
  return bloc.some((ligne, i) =>
    ligne.some((val, j) =>
      val === 1 && (
        // Vérifier les carrés avec un carré noir entre eux horizontalement et verticalement
        (bloc[i][j + 2] === 1 && bloc[i][j + 1] === 0) || 
        (bloc[i][j - 2] === 1 && bloc[i][j - 1] === 0) || 
        (bloc[i + 2] && bloc[i + 2][j] === 1 && bloc[i + 1][j] === 0) || 
        (bloc[i - 2] && bloc[i - 2][j] === 1 && bloc[i - 1][j] === 0)
      )
  ));
}


// Vérifie si le bloc répond aux critères du niveau 3
function verifierNiveau3(bloc) {
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

// Vérifie si le bloc répond aux critères du niveau 4
function verifierNiveau4(bloc) {
  // Niveau 4: Carrés blancs dans des coins opposés
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

function verifierNiveaum1(bloc) {
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

console.log("niveau 0 = " + verifierNiveau0(blocExemple));
console.log("niveau 1 = " + verifierNiveau1(blocExemple));
console.log("niveau 2 = " + verifierNiveau2(blocExemple));
console.log("niveau 3 = " + verifierNiveau3(blocExemple));
console.log("niveau 4 = " + verifierNiveau4(blocExemple));
console.log("niveau -1 = " + verifierNiveaum1(blocExemple));


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
 * Fonction qui sert à générer les "listes de listes de listes" que sont les matrices,
 * à partir d'un nombre binaire
 * @param {*} n nombre total de chiffres du nombre binaire
 * @param {*} k nombre de "1" du nombre binaire
 * @param {*} prefixe contenu du résultat
 * @param {*} blocSize taille du bloc
 * @returns 
 */
function genererCombinaisons(n, k, prefixe = '', blocSize = 3) {
  if (k === 0) {
    let bloc = genererBloc(prefixe, blocSize);
    tousLesBlocs.push(bloc);

    if (areOnesConnected(bloc)) {
       blocsContinus.push(bloc);
     } else {
       blocsBrises.push(bloc);
     }

    return;
  }
  if (n === 0) {
    return;
  }
  genererCombinaisons(n - 1, k, prefixe + '0', blocSize);
  genererCombinaisons(n - 1, k - 1, prefixe + '1', blocSize);
}
/**
 * Fonction qui génère un bloc à partir d'un nombre binaire
 * @param {*} binaire un binaire
 * @param {*} blocSize taille du bloc
 * @returns 
 */
function genererBloc(binaire, blocSize) {
  //Ajout préalable de 0 à la fin des binaires
  while (binaire.length != 9) {
    binaire += "0";
  }
  let bloc = [];
  let compteur = 0;
  for (let i = 0; i < blocSize; i++) {
    let row = [];
    for (let j = 0; j < blocSize; j++) {
      row.push(parseInt(binaire.charAt(compteur)));
      compteur++;
    }
    bloc.push(row);
  }
  return bloc;
}

let nombreCarresBlancs = 5;
// Appel de la fonction avec n=9 (nombre de chiffres) et k=5 (nombre de "1")
genererCombinaisons(9, nombreCarresBlancs);

// Pour des raisons d'affichage, je reverse les listes :
tousLesBlocs.reverse();
blocsContinus.reverse();
blocsBrises.reverse();

let blocsAffiches = [];
  
let scaling = 9;
let rownumber = 9;
let elementsPerRow = Math.ceil(tousLesBlocs.length / rownumber);
let squareSize = 3; // Taille du carré (3x3, 4x4, etc.)
let lineWidth = 1; // Largeur de la ligne verticale
let canvasWidth = elementsPerRow * (squareSize * scaling + lineWidth) - lineWidth;
let canvasHeight = rownumber * squareSize * scaling;
let decalageHorizontal = 0;
let sliderNombreCarres;
let sliderNombreCarresLegende;
let radioTypeBlocs;
let radioTypeBlocsLegende;
let positionIHMx = 300;
let positionIHMy = 300;
let positionIHMFiltresy = 130;

let minWidth = 1000; // Largeur minimale du canvas
let minHeight = 1000; // Hauteur minimale du canvas

let totalWidth = squareSize * scaling + lineWidth;
let gridStartX = 0; // À mettre à jour si la grille ne commence pas à x=0
let gridStartY = 0; // À mettre à jour si la grille ne commence pas à y=0

let gridEndX = gridStartX + elementsPerRow * totalWidth;
let gridEndY = gridStartY + rownumber * (squareSize * scaling);

let cnv;

function preload() {
	exempleBlocContinu = loadImage("blocs-6_19.png");
	exempleBlocBrise = loadImage("blocs-5_09.png");
	exemplePattern0 = loadImage("blocs-2_22.png");
	exemplePattern1 = loadImage("blocs-2_04.png");
	exemplePattern2 = loadImage("blocs-2_05.png");
	exemplePattern3 = loadImage("blocs-2_23.png");
	exemplePattern4 = loadImage("blocs-2_08.png");
	exemplePatterm1 = loadImage("bloc-0.png");
}

function setup() {
  sliderNombreCarres = createSlider(0, 9, nombreCarresBlancs, 1);
  sliderNombreCarres.position(positionIHMx + 20, positionIHMy + 50);
  sliderNombreCarres.style('width', '200px');
  sliderNombreCarresLegende = createP(`${sliderNombreCarres.value()}`);
  sliderNombreCarresLegende.position(positionIHMx + 50, positionIHMy + 20);

  radioTypeBlocs = createRadio();
  radioTypeBlocs.option('Tous');
  radioTypeBlocs.option('Continus');
  radioTypeBlocs.option('Brisés');
  radioTypeBlocs.position(positionIHMx + 20, positionIHMy + 100);
  radioTypeBlocs.selected('Tous');
  radioTypeBlocsLegende = createP();
  radioTypeBlocsLegende.position(positionIHMx + 50, positionIHMy + 70);
  radioTypeBlocsLegende.html(`Type de blocs affichés`);

  nombreBlocs = createP();
  nombreBlocs.position(positionIHMx + 50, positionIHMy + positionIHMFiltresy);
  nombreBlocs.html(`Application de filtres`);

  checkbox0 = createCheckbox('Pattern 0', false);
  checkbox1 = createCheckbox('Pattern 1', false);
  checkbox2 = createCheckbox('Pattern 2', false);
  checkbox3 = createCheckbox('Pattern 3', false);
  checkbox4 = createCheckbox('Pattern 4', false);
  checkbom1 = createCheckbox('Pattern -1', false);
  checkbox0.position(positionIHMx + 20, positionIHMy + positionIHMFiltresy + 30);
  checkbox1.position(positionIHMx + 20, positionIHMy + positionIHMFiltresy + 50);
  checkbox2.position(positionIHMx + 20, positionIHMy + positionIHMFiltresy + 70);
  checkbox3.position(positionIHMx + 20, positionIHMy + positionIHMFiltresy + 90);
  checkbox4.position(positionIHMx + 20, positionIHMy + positionIHMFiltresy + 110);
  checkbom1.position(positionIHMx + 20, positionIHMy + positionIHMFiltresy + 130);
  
  nombreBlocs = createP();
  nombreBlocs.position(positionIHMx+50, positionIHMy +270);
  nombreBlocs.html(`Nombre de blocs affichés : `);

  canvasWidth = elementsPerRow * (squareSize * scaling + lineWidth) - lineWidth;
  canvasHeight = rownumber * squareSize * scaling;

  canvasWidth = max(canvasWidth, minWidth);
  canvasHeight = max(canvasHeight, minHeight);

  cnv = createCanvas(canvasWidth, canvasHeight);
  cnv.id('mycanvas');
  background(15);
}

function draw() {
  let val = sliderNombreCarres.value();
  sliderNombreCarresLegende.html(`Carrés blancs par bloc : ${val}`);
  // Réinitialisation des listes
  tousLesBlocs = [];
  blocsContinus = [];
  blocsBrises = [];

  // Génération des nouveaux blocs
  genererCombinaisons(9, val);

  tousLesBlocs.reverse();
  blocsContinus.reverse();
  blocsBrises.reverse();

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
  if (checkbox0.checked()) {
    blocsAffiches = blocsAffiches.filter(verifierNiveau0);
  }
  if (checkbox1.checked()) {
    blocsAffiches = blocsAffiches.filter(verifierNiveau1);
  }
  if (checkbox2.checked()) {
    blocsAffiches = blocsAffiches.filter(verifierNiveau2);
  }
  if (checkbox3.checked()) {
    blocsAffiches = blocsAffiches.filter(verifierNiveau3);
  }
  if (checkbox4.checked()) {
    blocsAffiches = blocsAffiches.filter(verifierNiveau4);
  }
  if (checkbom1.checked()) {
    blocsAffiches = blocsAffiches.filter(verifierNiveaum1);
  }

  nombreBlocs.html(`Nombre de blocs affichés : ${blocsAffiches.length}`);

  elementsPerRow = Math.ceil(blocsAffiches.length / rownumber);
  canvasWidth = elementsPerRow * (squareSize * scaling + lineWidth) - lineWidth;
  canvasHeight = rownumber * squareSize * scaling;
  canvasWidth = max(canvasWidth, minWidth);
  canvasHeight = max(canvasHeight, minHeight);

  resizeCanvas(canvasWidth, canvasHeight);

  // Mise à jour de l'affichage
  background(15); // Nettoie le canvas avant de redessiner
  image(exempleBlocContinu,383,400);
  image(exempleBlocBrise,447,400);
  image(exemplePattern0,383,442);
  image(exemplePattern1,383,462);
  image(exemplePattern2,383,482);
  image(exemplePattern3,383,502);
  image(exemplePattern4,383,522);
  image(exemplePatterm1,383,542);

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
        decalageHorizontal += squareSize * scaling + lineWidth;
      }
    }
    decalageHorizontal = 0; // Réinitialiser le décalage pour chaque ligne
  }

  drawHoverSquare();
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
      square(gridX * totalWidth , gridY * squareSize * scaling, squareSize * scaling);
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
                      pg.fill(255); // Couleur des carrés pleins
                      pg.noStroke();
                      pg.square(j * scaling, i * scaling, scaling);
                  }
              }
          }

          // Enregistre le graphique en tant que fichier PNG
          save(pg, `blocs-${sliderNombreCarres.value()}_${index}.png`);
      }
  }
}