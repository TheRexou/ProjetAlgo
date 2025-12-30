// Projet: gestion simple d'un service de mentorat entre étudiants
// Description: Types et fonctions pour gérer étudiants, offres et demandes,
//              menu interactif en ligne de commande pour création, modification
//              suppression et recherche. Le code est commenté pour un lecteur
//              connaissant les bases de Swift (structures, fonctions, boucles).
// Comment exécuter le programme :
// - Se rendre dans le dossier du projet avec le terminal
// - Exécuter la commande : “swift run” dans le terminal
import Foundation
 
// ===== STRUCTURES DE DONNÉES =====
 
/// Représente un étudiant du système.
/// Contient les informations personnelles, rôles et disponibilités.
struct Student {
    var id: UInt
    var last_name: String
    var first_name: String
    var email: String
    var telephone: String
    var telephoneVisible: Bool
    var stud_class: String
    var roles: [String]
    var availability: [[Double]]
    var weaknesses: [String]
    var strengths: [String]
    var available: Bool
}
 
/// Représente une offre d'aide publiée par un parrain.
struct Offer {
    var id: UInt
    var student: Student
    var field: String
    var helpType: String
    var active: Bool
    var date: Date
}
 
/// Représente une demande d'aide publiée par un filleul.
struct Request {
    var id: UInt
    var student: Student
    var field: String
    var description: String
    var level: String
    var active: Bool
    var date: Date
}
 
// ===== DONNÉES GLOBALES =====
 
let lsHelpTypes: [String] = [
    "Leçon complète", "Explication d'un point", "Résolution d'exercices"
]
 
let days: [String] = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
 
 
// ###################################################
// ################# FAIT PAR DOKAN ##################
// ###################################################
 
 
// ===== FONCTIONS UTILITAIRES =====
/// Vérifie si `input` correspond au `regex` fourni.
/// - Parameters:
///   - input: chaîne à tester
///   - regex: expression régulière (format Swift)
/// - Returns: `true` si la chaîne correspond, `false` sinon
func matchToRegex(input:String, regex:String) -> Bool {
    if (input.range(of: regex, options: .regularExpression) != nil) { // Cherche si le regex correspond
        return true // Oui, c'est valide
    } else {
        print("La saisie est invalide, réessayez.") // Affiche un message d'erreur
        return false // Non, ce n'est pas valide
    }
}
 
/// Vérifie que l'intervalle horaire de la forme "HHhMM - HHhMM" est valide
/// (heure de fin strictement après heure de début).
/// - Parameter input: chaîne au format "HHhMM - HHhMM"
/// - Returns: `true` si la plage est valide, `false` sinon
func isValidTimeRange(input: String) -> Bool {
    // Extraction
    let parts: [String] = input.components(separatedBy: " - ")
    let start: String = parts[0]
    let end: String = parts[1]
 
    func minutes(from time: String) -> Int {
        let comps: [String.SubSequence] = time.split(separator: "h")
        let hours: Int = Int(comps[0])!
        let minutes: Int = Int(comps[1])!
        return hours * 60 + minutes
    }
 
    let valide: Bool = minutes(from: end) > minutes(from: start)
 
    if (valide) {
        return true
    } else {
        print("L'heure de fin doit être supérieur à l'heure de début, réessayer.")
        return false
    }
}
 
/// Recherche interactive d'un étudiant par nom puis par ID.
/// Utilise une saisie insensible à la casse et vérifie le format des entrées.
/// - Parameter lsStudent: liste des étudiants modifiable (référence)
/// - Returns: l'`Etudiant` trouvé
func findStudent(lsStudent: inout [Student]) -> Student {
    var resultLine: String
    print("\nVeuillez saisir votre nom:")
 
    // Convertit le nom en minuscules pour une recherche insensible à la casse
    resultLine = readLineUntilNotEmpty().lowercased()
 
    var valideFormat: Bool = matchToRegex(input: resultLine, regex: "^[A-Za-z]+$")
    var studentFound: Bool = false
    // Boucle jusqu'à ce que le format soit correct
    repeat {
 
        if (valideFormat) {
            var resultEtudiant: [Student] = []
            for etudiant: Student in lsStudent {
                if etudiant.last_name.lowercased().contains(resultLine) {
                    studentFound = true
                    resultEtudiant.append(etudiant)
                }
            }
 
            print("\n-------------------------------------------\n")
            if studentFound {
                for etudiant: Student in resultEtudiant {
                    print(
                        "Id: \(etudiant.id)\t\tNom: \(etudiant.last_name)\t\tPrénom: \(etudiant.first_name)\t\tAdresse mail: \(etudiant.email)"
                    )
                }
            } else {
                print("Impossible de trouver l'étudiant, réessayez")
            }
            print("\n-------------------------------------------")
 
        }
 
        if (!valideFormat || !studentFound) {
            print("Veuillez saisir votre nom :")
            resultLine = readLineUntilNotEmpty()
            valideFormat = matchToRegex(input: resultLine, regex: "^[A-Za-z]+$")
        }
 
    } while (!valideFormat || !studentFound)
 
    // Demande l'ID pour identifier précisément l'étudiant (évite les homonymes)
    print("\nVeuillez saisir votre id:")
 
    resultLine = readLineUntilNotEmpty()
 
    valideFormat = matchToRegex(input: resultLine, regex: "^[0-9]+$")
    var valideId: Bool = false
    // Boucle jusqu'à ce que le format soit correct
    repeat {
 
        if (valideFormat) {
            
            valideId = Int(resultLine)! < lsStudent.count
            if !valideId {
                print("\nImpossible d'avoir un id plus grand que \(lsStudent.count - 1), réessayez")
            }
        }
 
        if (!valideFormat || !valideId) {
            print("Veuillez saisir votre id :")
            resultLine = readLineUntilNotEmpty()
            valideFormat = matchToRegex(input: resultLine, regex: "^[0-9]+$")
        }
 
    } while (!valideFormat || !valideId)
 
    // Utilise la recherche binaire pour retrouver l'étudiant dans la liste par son ID (très rapide)
    return lsStudent[searchStudent(lsStudent: &lsStudent, studentId: Int(resultLine)!)]
}
 
// ===== GESTION DES ÉTUDIANTS =====
/// Lance un formulaire interactif dans la console pour créer un nouvel `Etudiant`.
/// - Parameters:
///   - lsStudent: liste des étudiants (modifiée si création)
///   - lsField: liste des domaines disponibles (utilisée pour points faibles/forts)
func createStudent(lsStudent: inout [Student], lsField: [String]) {
    // Variable pour stocker la saisie utilisateur
    var resultLine: String
 
    // ---- Collecte le NOM ----
    print("\nNom de l'étudiant :")
    var name: String = ""
    resultLine = readLineUntilNotEmpty()
    // Boucle jusqu'à ce que le nom soit valide (seulement des lettres)
    while (!matchToRegex(input: resultLine, regex: "^[A-Za-z]+$")) {
        print("Nom de l'étudiant :")
        resultLine = readLineUntilNotEmpty()
    }
    name = resultLine // Stocke le nom validé
 
    // ---- Collecte le PRÉNOM ----
    print("\nPrénom de l'étudiant :")
    var firstName: String = ""
    resultLine = readLineUntilNotEmpty()
    while (!matchToRegex(input: resultLine, regex: "^[A-Za-z]+$")) {
        print("Prénom de l'étudiant :")
        resultLine = readLineUntilNotEmpty()
    }
    firstName = resultLine
 
    // ---- Collecte l'EMAIL ----
    print("\nAddresse e-mail de l'étudiant :")
    var email: String = ""
    resultLine = readLineUntilNotEmpty()
    // Vérifie que c'est un email valide (format: xxx@xxx.xxx)
    while (!matchToRegex(input: resultLine, regex: #"^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$"#)) {
        print("Addresse e-mail de l'étudiant :")
        resultLine = readLineUntilNotEmpty()
    }
    email = resultLine
    
    // ---- Collecte le TÉLÉPHONE (optionnel) ----
    print("\nNuméro de téléphone de l'étudiant (<0> pour ne rien mettre) :")
    var phoneNumber: String = ""
    resultLine = readLineUntilNotEmpty()
    // Vérifie que c'est un numéro valide (chiffres uniquement, optionnel +)
    // On ne vérifie pas si le numéro est d'un certain format car il peut y avoir des numéros internationaux
    while (!matchToRegex(input: resultLine, regex: #"^\+?[0-9]+$"#)) {
        print("Numéro de téléphone de l'étudiant (<0> pour ne rien mettre) :")
        resultLine = readLineUntilNotEmpty()
    }
    phoneNumber = resultLine
 
    // ---- Demande la visibilité du TÉLÉPHONE ----
    var phoneNumberVisible: Bool = false // Par défaut, le téléphone n'est pas visible
    // Si un téléphone a été fourni alors demander s'il doit être visible
    if phoneNumber != "0" {
        print("\nLe numéro de téléphone doit être visible ? (oui / NON) :")
        resultLine = readLine()!
        if resultLine.lowercased() == "oui" {
            phoneNumberVisible = true
        }
    }
    
    // ---- Collecte la PROMOTION (année/classe) ----
    print("\nPromotion & année de l'étudiant :")
    var promotion: String = ""
    resultLine = readLineUntilNotEmpty()
    while (!matchToRegex(input: resultLine, regex: "^[A-Za-z0-9 ]+$")) {
        print("Promotion & année de l'étudiant :")
        resultLine = readLineUntilNotEmpty()
    }
    promotion = resultLine
 
    // ---- Collecte les RÔLES (Parrain et/ou Filleul) ----
    var roles: [String] = []
    // Continue à boucler jusqu'à ce qu'au moins un rôle soit sélectionné
    repeat {
        print("\nRôle(s) de l'étudiant (au moins un) :")
        print("L'étudiant est-il un parrain ? (oui / NON) :")
        resultLine = readLine()!
        if resultLine.lowercased() == "oui" {
            roles.append("Parrain")
        }
        print("L'étudiant est-il un filleul ? (oui / NON) :")
        resultLine = readLine()!
        if resultLine.lowercased() == "oui" {
            roles.append("Filleul")
        }
        if roles.isEmpty {
            print("Au moins un rôle doit être sélectionné.")
        }
    } while (roles.isEmpty)
 
    // ---- Collecte les DISPONIBILITÉS (jours de la semaine) ----
    print("\nL'étudiant est disponible (séparés par des virgules) :")
    // Tableau pour stocker les disponibilités [[début, fin]] la position dans le tableau correspond au jour de la semaine
    var availability: [[Double]] = []
    // Affiche les jours disponibles
    for day: String in days {
        print("- \(day)")
    }
    
    // Jours de disponibilité choisis par l'utilisateur
    var daysAvailable: [String] = [] // Tableau temporaire pour les jours choisis
    // Boucle jusqu'à ce qu'au moins un jour valide soit choisi
    repeat {
        resultLine = readLineUntilNotEmpty()
        // Divise la saisie par des virgules et convertit en minuscules
        let daysAvailableTemp: [String] = resultLine.lowercased().components(separatedBy: ",")
        // Crée une version en minuscules de la liste des jours pour comparer
        let daysLowercased: [String] = days.map { $0.lowercased() }
        // Parcourt chaque jour saisi
        for dayAvailable: String in daysAvailableTemp {
            // Supprime les espaces avant et après (avec trim)
            let dayTrimmed: String = dayAvailable.trimmingCharacters(in: .whitespacesAndNewlines)
            // Vérifie si ce jour existe dans la liste
            if daysLowercased.contains(dayTrimmed) {
                // Si le jour est valide, l'ajouter au tableau des jours availables
                daysAvailable.append(dayTrimmed)
            }
        }
        // Si aucun jour valide n'a été trouvé, demande à nouveau
        if daysAvailable.isEmpty {
            print("Au moins un jour de disponibilité doit être sélectionné (séparés par des virgules) :")
            for day: String in days {
                print("- \(day)")
            }
        }
    } while (daysAvailable.isEmpty)
 
    // ---- Collecte les HORAIRES pour chaque jour de la semaine ----
    // Pour chaque jour de la semaine
    for day: String in days {
        var matchDay: Bool = false // Indique si ce jour a été sélectionné
        // Vérifie si ce jour est dans la liste des jours disponibles
        for dayAvailable: String in daysAvailable {
            if day.lowercased() == dayAvailable{
                matchDay = true // Marque le jour comme trouvé
                print("\nHorraire de disponibilité pour \(day) (ex : 08h00 - 11h30) :")
                // Regex complexe pour vérifier le format des horaires (HHhMM - HHhMM)
                let pattern: String = #"^(?:[0-1][0-9]|2[0-3])h[0-5][0-9] - (?:[0-1][0-9]|2[0-3])h[0-5][0-9]$"#
                resultLine = readLineUntilNotEmpty()
                
                var valideFormat: Bool = matchToRegex(input: resultLine, regex: pattern)
                var valideTime: Bool = false
                // Boucle jusqu'à ce que le format soit correct
                repeat {
 
                    if (valideFormat) {
                        // Vérifie que l'heure de fin est bien après l'heure de début
                        valideTime = isValidTimeRange(input: resultLine)
                    }
 
                    if (!valideFormat || !valideTime) {
                        print("Horraire de disponibilité pour \(day) (ex : 08h00 - 11h30) :")
                        resultLine = readLineUntilNotEmpty()
                        valideFormat = matchToRegex(input: resultLine, regex: pattern)
                    }
                } while (!valideFormat || !valideTime)
                // Ajoute les horaires validés au tableau
                let availabilitytart: Double = Double(resultLine.prefix(5).replacingOccurrences(of: "h", with: "."))!
                let disponibiliteEnd: Double = Double(resultLine.suffix(5).replacingOccurrences(of: "h", with: "."))!
                availability.append([availabilitytart, disponibiliteEnd])
            }
        }
        // Si ce jour n'était pas sélectionné, ajoute "Non disponible"
        if !matchDay {
            availability.append([-1, -1]) // -1 pour indiquer non disponible
        }
    }
    
    // ---- Collecte les POINTS FAIBLES (domaines à améliorer) ----
    var weaknesses: [String] = []
    // Uniquement si l'étudiant est filleul
    if roles.contains("Filleul") {
        print("\nPoint(s) faible(s) de l'étudiant (séparés par des virgules) :")
        // Boucle jusqu'à ce qu'au moins un domaine faible soit sélectionné
        repeat {
            // Affiche tous les domaines disponibles
            for domaine: String in lsField {
                print("- \(domaine)")
            }
            // Récupère la saisie et convertit en minuscules
            resultLine = readLineUntilNotEmpty().lowercased()
            // Divise par des virgules
            let weaknessesTemp: [String] = resultLine.components(separatedBy: ",")
            // Crée une version en minuscules de la liste des domaines pour comparer
            let lsFieldLowercased: [String] = lsField.map { $0.lowercased() }
            // Pour chaque domaine saisi
            for pointFaible: String in weaknessesTemp {
                // Vérifie s'il existe dans lsField (avec suppression des espaces)
                if lsFieldLowercased.contains(pointFaible.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    // Si valide, l'ajoute au tableau
                    
                    // Recherche le domaine dans la liste initial (lsField) pour l'ajouter dans weaknesses
                    let indexDomaine: Array<String>.Index = lsFieldLowercased.firstIndex(of: pointFaible.trimmingCharacters(in: .whitespacesAndNewlines))!
                    weaknesses.append(lsField[indexDomaine])
                }
            }
            // Si aucun domaine valide n'a été trouvé
            if weaknesses.isEmpty {
                print("Au moins un point faible doit être sélectionné (séparés par des virgules) :")
            }
        } while (weaknesses.isEmpty)
        
    }
    
    // ---- Collecte les POINTS FORTS (domaines d'expertise) ----
    var strengths: [String] = []
    // Uniquement si l'étudiant est parrain (il peut offrir de l'aide)
    if roles.contains("Parrain") {
        print("\nPoint(s) fort(s) de l'étudiant (séparés par des virgules) :")
        // Boucle jusqu'à ce qu'au moins un domaine fort soit sélectionné
        repeat {
            // Affiche tous les domaines disponibles
            for domaine: String in lsField {
                print("- \(domaine)")
            }
            // Récupère la saisie et convertit en minuscules
            resultLine = readLineUntilNotEmpty().lowercased()
            // Divise par des virgules
            let strengthsTemp: [String] = resultLine.components(separatedBy: ",")
            // Crée une version en minuscules de la liste des domaines pour comparer
            let lsFieldLowercased: [String] = lsField.map { $0.lowercased() }
            // Pour chaque domaine saisi
            for pointFort: String in strengthsTemp {
                // Vérifie s'il existe dans lsField (avec suppression des espaces)
                if lsFieldLowercased.contains(pointFort.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    // Si valide, l'ajoute au tableau
                    
                    // Recherche le domaine dans la liste initial (lsField) pour l'ajouter dans strengths
                    let indexDomaine: Array<String>.Index = lsFieldLowercased.firstIndex(of: pointFort.trimmingCharacters(in: .whitespacesAndNewlines))!
                    strengths.append(lsField[indexDomaine])
                }
            }
            // Si aucun domaine valide n'a été trouvé
            if strengths.isEmpty {
                print("Au moins un point fort doit être sélectionné (séparés par des virgules) :")
            }
        } while (strengths.isEmpty)
    }
 
    // ---- Demande la DISPONIBILITÉ ACTUELLE ----
    print("\nL'étudiant est actuellement disponible ? (OUI / non) :")
    resultLine = readLine()!
    var disponible: Bool = true // Par défaut: disponible
    if resultLine == "Non" {
        disponible = false // Marque comme non disponible
    }
 
    // ---- CRÉATION du nouvel étudiant avec toutes les informations collectées ----
    var newStudent: Student = Student(
        id: UInt(lsStudent.count),
        last_name: name,
        first_name: firstName,
        email: email,
        telephone: phoneNumber,
        telephoneVisible: phoneNumberVisible,
        stud_class: promotion,
        roles: roles,
        availability: availability,
        weaknesses: weaknesses,
        strengths: strengths,
        available: disponible
    )
 
    // ---- VÉRIFICATION des doublons avant d'ajouter l'étudiant ----
    // Vérifie qu'aucun étudiant n'a le même email ou téléphone
    if (!isDuplicateStudent(lsStudent: &lsStudent, newStudent: &newStudent)) {
        lsStudent.append(newStudent) // Ajoute le nouvel étudiant à la liste
        print("Étudiant créé avec succès !")
    } else {
        print("Erreur : Un étudiant avec le même email ou numéro de téléphone existe déjà.")
    }
}
 
// ===== GESTION DE LA MODIFICATION D'ÉTUDIANTS =====
/// Permet de modifier (interactivement) les champs d'un `Etudiant` existant.
/// - Parameters:
///   - lsStudent: liste des étudiants (référence)
///   - lsField: domaines valides pour points faibles/forts
func modifyStudent(lsStudent: inout [Student], lsField: [String]) {
    var resultLine: String
 
    // ---- ÉTAPE 1: IDENTIFICATION DE L'ÉTUDIANT ----
    var etudiant: Student = findStudent(lsStudent: &lsStudent)
 
    // ---- ÉTAPE 2: MENU DE MODIFICATION ----
    // Affiche le menu et les champs modifiables
    print("\nQue souhaite-vous modifier de l'étudiant '\(etudiant.last_name) \(etudiant.first_name)' ?")
    print("\nModifiable: nom, prénom, adresse email, téléphone, visibilité du téléphone, promotion, rôles, disponibilités, points faibles, points forts, disponible")
    print("Entrez 'quitter' pour terminer la modification.")
    resultLine = readLineUntilNotEmpty().lowercased()
    
    // Boucle de modification: l'utilisateur peut changer plusieurs champs avant de quitter
    while (resultLine != "quitter") {
        switch resultLine {
            // ---- CAS: Modification du NOM ----
            case "nom":
                print("\nNom actuel : \(etudiant.last_name)")
                print("\nNouveau nom :")
                resultLine = readLineUntilNotEmpty()
                while (!matchToRegex(input: resultLine, regex: "^[A-Za-z]+$")) {
                    print("Nouveau nom :")
                    resultLine = readLineUntilNotEmpty()
                }
                etudiant.last_name = resultLine // Met à jour le nom après validation
                
            // ---- CAS: Modification du PRÉNOM ----
            case "prénom":
                print("\nPrénom actuel : \(etudiant.first_name)")
                print("\nNouveau prénom :")
                resultLine = readLineUntilNotEmpty()
                while (!matchToRegex(input: resultLine, regex: "^[A-Za-z]+$")) {
                    print("Nouveau prénom :")
                    resultLine = readLineUntilNotEmpty()
                }
                etudiant.first_name = resultLine
                
            // ---- CAS: Modification de l'ADRESSE EMAIL ----
            case "adresse email":
                print("\nAddresse email actuelle : \(etudiant.email)")
                print("\nNouvelle adresse email :")
                resultLine = readLineUntilNotEmpty()
                while (!matchToRegex(input: resultLine, regex: #"^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$"#)) {
                    print("Nouvelle adresse email :")
                    resultLine = readLineUntilNotEmpty()
                }
                etudiant.email = resultLine
 
            // ---- CAS: Modification du TÉLÉPHONE ----
            case "téléphone":
                print("\nNuméro de téléphone actuel : \(etudiant.telephone == "0" ? "Non défini" : etudiant.telephone)")
                print("\nNouveau numéro de téléphone (<0> pour ne rien mettre):")
                resultLine = readLineUntilNotEmpty()
                
                // Validation: vérifie que c'est un numéro valide (chiffres et + pour formats internationaux)
                // Nous acceptons les formats internationaux car les numéros peuvent venir de pays différents
                while (!matchToRegex(input: resultLine, regex: #"^\+?[0-9]+$"#)) {
                    print("Nouveau numéro de téléphone (<0> pour ne rien mettre) :")
                    resultLine = readLineUntilNotEmpty()
                }
                etudiant.telephone = resultLine
 
                if (etudiant.telephone != "0") {
                    print("\nLe numéro de téléphone doit être visible ? (oui / NON) :")
                    resultLine = readLine()!
                    // Si l'utilisateur répond "oui", on rend le téléphone visible
                    if resultLine.lowercased() == "oui" {
                        etudiant.telephoneVisible = true
                    } else {
                        // Sinon, on le rend invisible (par défaut)
                        etudiant.telephoneVisible = false
                    }
                }
                
            // ---- CAS: Modification de la VISIBILITÉ du TÉLÉPHONE ----
            case "visibilité du téléphone":
                if (etudiant.telephone != "0") {
                    print("\nVisibilité actuelle du numéro de téléphone : \(etudiant.telephoneVisible ? "Visible" : "Non visible")")
                    print("\nLe numéro de téléphone doit être visible ? (oui / NON) :")
                    resultLine = readLine()!
                    // Si l'utilisateur répond "oui", on rend le téléphone visible
                    if resultLine.lowercased() == "oui" {
                        etudiant.telephoneVisible = true
                    } else {
                        // Sinon, on le rend invisible (par défaut)
                        etudiant.telephoneVisible = false
                    }
                } else {
                    print("\nVous devez d'abord définir un numéro de téléphone")
                }
                
            // ---- CAS: Modification de la PROMOTION ----
            case "promotion":
                print("\nPromotion & année actuelle : \(etudiant.stud_class)")
                print("\nNouvelle promotion & année :")
                resultLine = readLineUntilNotEmpty()
                
                while (!matchToRegex(input: resultLine, regex: "^[A-Za-z0-9 ]+$")) {
                    print("Promotion & année de l'étudiant :")
                    resultLine = readLineUntilNotEmpty()
                }
                etudiant.stud_class = resultLine
 
            // ---- CAS: Modification des RÔLES ----
            case "rôles":
                print("\nRôle(s) actuel(s) : \(etudiant.roles.joined(separator: ", "))")
                var roles: [String] = []
                
                // Boucle jusqu'à ce qu'au moins un rôle soit choisi
                repeat {
                    print("\nRôle(s) de l'étudiant (au moins un) :")
                    print("L'étudiant est-il un parrain ? (oui / NON) :")
                    resultLine = readLine()!
                    // Si l'utilisateur répond "oui", ajoute le rôle Parrain
                    if resultLine.lowercased() == "oui" {
                        roles.append("Parrain")
                    }
                    print("\nL'étudiant est-il un filleul ? (oui / NON) :")
                    resultLine = readLine()!
                    // Si l'utilisateur répond "oui", ajoute le rôle Filleul
                    if resultLine.lowercased() == "oui" {
                        roles.append("Filleul")
                    }
                    // Si aucun rôle n'a été sélectionné, demande à nouveau
                    if roles.isEmpty {
                        print("Au moins un rôle doit être sélectionné.")
                    }
                } while (roles.isEmpty)
                
                // Si l'étudiant ne sera plus Filleul, supprime ses points faibles
                if !roles.contains("Filleul") {
                    etudiant.weaknesses = []
                } else if etudiant.weaknesses.isEmpty {
                    // Si maintenant c'est un Filleul ET qu'il n'a pas de points faibles, on demande d'en ajouter
                    print("\nL'étudiant est maintenant filleul, veuillez ajouter des points faibles.")
                    var weaknesses: [String] = []
                    repeat {
                        print("\nPoint(s) faible(s) de l'étudiant (séparés par des virgules) :")
                        // Affiche les domaines disponibles
                        for domaine: String in lsField {
                            print("- \(domaine)")
                        }
                        // Récupère les domaines saisis par l'utilisateur
                        resultLine = readLineUntilNotEmpty().lowercased()
                        let weaknessesTemp: [String] = resultLine.components(separatedBy: ",")
                        let lsFieldLowercased: [String] = lsField.map { $0.lowercased() }
                        // Valide que chaque point faible est dans la liste des domaines
                        for pointFaible: String in weaknessesTemp {
                            if lsFieldLowercased.contains(pointFaible.trimmingCharacters(in: .whitespacesAndNewlines)) {
                                // Le point faible est valide, on l'ajoute
                                
                                // Recherche le domaine dans la liste initial (lsField) pour l'ajouter dans weaknesses
                                let indexDomaine: Array<String>.Index = lsFieldLowercased.firstIndex(of: pointFaible.trimmingCharacters(in: .whitespacesAndNewlines))!
                                weaknesses.append(lsField[indexDomaine])
                            }
                        }
 
                        // Si aucun domaine valide n'a été trouvé
                        if weaknesses.isEmpty {
                            print("Au moins un point faible doit être sélectionné (séparés par des virgules) :")
                        }
                    } while (weaknesses.isEmpty)
 
                    etudiant.weaknesses = weaknesses
                }
                
                // Si l'étudiant ne sera plus Parrain, supprime ses points forts
                if !roles.contains("Parrain") {
                    etudiant.strengths = []
                } else if etudiant.strengths.isEmpty {
                    // Si maintenant c'est un Parrain ET qu'il n'a pas de points forts, on demande d'en ajouter
                    print("\nL'étudiant est maintenant parrain, veuillez ajouter des points forts.")
                    var strengths: [String] = []
                    repeat {
                        print("\nPoint(s) fort(s) de l'étudiant (séparés par des virgules) :")
                        // Affiche les domaines disponibles
                        for domaine: String in lsField {
                            print("- \(domaine)")
                        }
                        // Récupère les domaines saisis par l'utilisateur
                        resultLine = readLineUntilNotEmpty().lowercased()
                        let strengthsTemp: [String] = resultLine.components(separatedBy: ",")
                        // Crée une version en minuscules de la liste des domaines pour comparer
                        let lsFieldLowercased: [String] = lsField.map { $0.lowercased() }
                        // Valide que chaque point fort est dans la liste des domaines
                        for pointFort: String in strengthsTemp {
                            if lsFieldLowercased.contains(pointFort.trimmingCharacters(in: .whitespacesAndNewlines)) {
                                // Le point fort est valide, on l'ajoute
                                
                                // Recherche le domaine dans la liste initial (lsField) pour l'ajouter dans strengths
                                let indexDomaine: Array<String>.Index = lsFieldLowercased.firstIndex(of: pointFort.trimmingCharacters(in: .whitespacesAndNewlines))!
                                strengths.append(lsField[indexDomaine])
                            }
                        }
 
                        // Si aucun domaine valide n'a été trouvé
                        if strengths.isEmpty {
                            print("Au moins un point fort doit être sélectionné (séparés par des virgules) :")
                        }
                    } while (strengths.isEmpty)
 
                    etudiant.strengths = strengths
                }
 
                etudiant.roles = roles
                
            // ---- CAS: Modification des DISPONIBILITÉS ----
            case "disponibilités":
                var availability: [[Double]] = etudiant.availability // Copie les disponibilités actuelles
                var counter: Int = 0
                print("\nDisponibilités actuelles :")
                // Affiche les horaires actuels pour chaque jour et fait en sorte d'affichier 'Non disponible' pour les jours ayant [-1, -1]
                for day: String in days {
                    if availability[counter][0] == -1 && availability[counter][1] == -1 {
                        print("- \(day) : \tNon disponible")
                    } else {
                        print("- \(day) : \tDe \(String(format: "%.2f", availability[counter][0]).replacingOccurrences(of: ".", with: "h")) à \(String(format: "%.2f", availability[counter][1]).replacingOccurrences(of: ".", with: "h"))")
                    }
                    counter += 1
                }
                print("\nChoisissez le jour à modifier :")
                resultLine = readLineUntilNotEmpty().trimmingCharacters(in: .whitespacesAndNewlines)
                let daysLowercased: [String] = days.map { $0.lowercased() }
                // Vérifie que le jour saisi existe dans la liste des jours
                if daysLowercased.contains(resultLine.lowercased()) {
                    let selectedDay: String = resultLine
                    print("\nNouvelle horraire de disponibilité pour \(resultLine) (ex : 08h00 - 11h30) :")
                    // Regex complexe: vérifie le format HHhMM - HHhMM
                    let pattern: String = #"^(?:[0-1][0-9]|2[0-3])h[0-5][0-9] - (?:[0-1][0-9]|2[0-3])h[0-5][0-9]$"#
                    resultLine = readLineUntilNotEmpty()
                    var valideFormat: Bool = matchToRegex(input: resultLine, regex: pattern)
                    var valideTime: Bool = false
                    // Boucle jusqu'à ce que le format soit correct
                    repeat {
 
                        if (valideFormat) {
                            // Vérifie que l'heure de fin est bien après l'heure de début
                            valideTime = isValidTimeRange(input: resultLine)
                        }
 
                        if (!valideFormat || !valideTime) {
                            print("Nouvelle horraire de disponibilité pour \(resultLine) (ex : 08h00 - 11h30) :")
                            resultLine = readLineUntilNotEmpty()
                            valideFormat = matchToRegex(input: resultLine, regex: pattern)
                        }
                    } while (!valideFormat || !valideTime)
                    
                    // Trouve l'index du jour et met à jour l'horaire pour ce jour
                    let dayIndex: Array<String>.Index = days.firstIndex(of: selectedDay)!
                    let availabilitytart: Double = Double(resultLine.prefix(5).replacingOccurrences(of: "h", with: "."))!
                    let disponibiliteEnd: Double = Double(resultLine.suffix(5).replacingOccurrences(of: "h", with: "."))!
                    availability[dayIndex] = [availabilitytart, disponibiliteEnd]
                    etudiant.availability = availability // Met à jour toutes les disponibilités
 
                } else {
                    print("\nJour non reconnu.")
                }
                
            // ---- CAS: Modification des POINTS FAIBLES ----
            case "points faibles":
                // Les points faibles ne s'appliquent QUE si l'étudiant est un Filleul
                if etudiant.roles.contains("Filleul") {
                    print("\nPoints faibles actuels : \(etudiant.weaknesses.joined(separator: ", "))")
                    var weaknesses: [String] = []
                    repeat {
                        print("\nPoint(s) faible(s) de l'étudiant (séparés par des virgules) :")
                        // Affiche les domaines disponibles
                        for domaine: String in lsField {
                            print("- \(domaine)")
                        }
                        // Récupère la saisie de l'utilisateur et valide
                        resultLine = readLineUntilNotEmpty()
                        let weaknessesTemp: [String] = resultLine.components(separatedBy: ",")
                        let lsFieldLowercased: [String] = lsField.map { $0.lowercased() }
                        // Vérifie que chaque domaine est dans la liste validée
                        for pointFaible: String in weaknessesTemp {
                            if lsFieldLowercased.contains(pointFaible.trimmingCharacters(in: .whitespacesAndNewlines)) {
                                // Le domaine est valide, on l'ajoute
 
                                // Recherche le domaine dans la liste initial (lsField) pour l'ajouter dans weaknesses
                                let indexDomaine: Array<String>.Index = lsFieldLowercased.firstIndex(of: pointFaible.trimmingCharacters(in: .whitespacesAndNewlines))!
                                weaknesses.append(lsField[indexDomaine])
                            }
                        }
 
                        // Si aucun domaine valide n'a été trouvé
                        if weaknesses.isEmpty {
                            print("Au moins un point faible doit être sélectionné (séparés par des virgules) :")
                        }
                    } while (weaknesses.isEmpty)
                    etudiant.weaknesses = weaknesses // Met à jour les points faibles
                } else {
                    // Si l'étudiant n'est pas Filleul, il n'a pas de points faibles
                    print("\nL'étudiant n'est pas filleul (pas de points faibles).")
                }
                
            // ---- CAS: Modification des POINTS FORTS ----
            case "points forts":
                // Les points forts ne s'appliquent QUE si l'étudiant est un Parrain
                if etudiant.roles.contains("Parrain") {
                    print("\nPoints forts actuels : \(etudiant.strengths.joined(separator: ", "))")
                    var strengths: [String] = []
                    repeat {
                        print("\nPoint(s) fort(s) de l'étudiant (séparés par des virgules) :")
                        // Affiche les domaines disponibles
                        for domaine: String in lsField {
                            print("- \(domaine)")
                        }
                        // Récupère la saisie de l'utilisateur et valide
                        resultLine = readLineUntilNotEmpty()
                        let strengthsTemp: [String] = resultLine.components(separatedBy: ",")
                        let lsFieldLowercased: [String] = lsField.map { $0.lowercased() }
                        // Vérifie que chaque domaine est dans la liste validée
                        for pointFort: String in strengthsTemp {
                            if lsFieldLowercased.contains(pointFort.trimmingCharacters(in: .whitespacesAndNewlines)) {
                                // Le domaine est valide, on l'ajoute
                                
                                // Recherche le domaine dans la liste initial (lsField) pour l'ajouter dans strengths
                                let indexDomaine: Array<String>.Index = lsFieldLowercased.firstIndex(of: pointFort.trimmingCharacters(in: .whitespacesAndNewlines))!
                                strengths.append(lsField[indexDomaine])
                            }
                        }
                        // Si aucun domaine valide n'a été trouvé
                        if strengths.isEmpty {
                            print("Au moins un point fort doit être sélectionné (séparés par des virgules) :")
                        }
                    } while (strengths.isEmpty)
                    etudiant.strengths = strengths // Met à jour les points forts
                } else {
                    // Si l'étudiant n'est pas Parrain, il n'a pas de points forts
                    print("\nL'étudiant n'est pas parrain (pas de points forts).")
                }
                
            // ---- CAS: Modification de la DISPONIBILITÉ ACTUELLE ----
            case "disponible":
                print("\nDisponibilité actuelle : \(etudiant.available ? "disponible" : "Non disponible")")
                print("\nL'étudiant est-il disponible ? (OUI / non) :")
                resultLine = readLine()!.lowercased()
                // Si l'utilisateur écrit "Non", marque comme non disponible
                if resultLine == "non" {
                    etudiant.available = false
                } else {
                    // Sinon, marque comme disponible (par défaut)
                    etudiant.available = true
                }
            // ---- CAS PAR DÉFAUT ----
            // Si l'utilisateur entre un champ qui n'existe pas
            default:
                print("\nRien n'était sélectionné ou mauvaise saisie.")
 
            // Met à jour l'étudiant dans la liste (important car nous travaillons sur une copie)
            lsStudent[Int(etudiant.id)] = etudiant
            print("\nÉtudiant modifié avec succès !")
        }
        // Redemande à l'utilisateur ce qu'il veut modifier ensuite
        print("\nQue souhaite-vous modifier de l'étudiant '\(etudiant.last_name) \(etudiant.first_name)' ?")
        print("\nModifiable: nom, prénom, adresse email, téléphone, visibilité du téléphone, promotion, rôles, disponibilités, points faibles, points forts, disponible")
        print("Entrez 'quitter' pour terminer la modification.")
        resultLine = readLineUntilNotEmpty().lowercased()
    }
 
    // ÉTAPE 3: Finalement, met à jour l'étudiant modifié dans la liste avec toutes les modifications
    lsStudent[Int(etudiant.id)] = etudiant
}
 
/// Affiche dans la console les informations complètes d'un étudiant sélectionné.
/// - Parameter lsStudent: liste des étudiants (référence pour la sélection)
func printStudent(lsStudent: inout [Student]) {
 
    // Identification interactive
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
 
    print("\n-------------------------------------------\n")
    print("Informations de l'étudiant '\(etudiant.last_name) \(etudiant.first_name)' :")
    print("ID : \t\t\t\(etudiant.id)")
    print("Nom : \t\t\t\(etudiant.last_name)")
    print("Prénom : \t\t\(etudiant.first_name)")
    print("Adresse email : \t\(etudiant.email)")
    if etudiant.telephone == "0" {
        print("Numéro de téléphone : \tNon défini")
    } else {
        if etudiant.telephoneVisible {
            print("Numéro de téléphone : \t\(etudiant.telephone)")
        } else {
            print("Numéro de téléphone : \tNon visible")
        }
    }
    print("Promotion & année : \t\(etudiant.stud_class)")
    print("Rôle(s) : \t\t\(etudiant.roles.joined(separator: ", "))")
    print("Disponibilités :")
    var counter: Int = 0
    for day: String in days {
        let disponibilite: [Double] = etudiant.availability[counter]
        if disponibilite[0] == -1 && disponibilite[1] == -1 {
            print("- \(day) : \t\tNon disponible")
        } else {
            print("- \(day) : \t\tDe \(String(format: "%.2f", disponibilite[0]).replacingOccurrences(of: ".", with: "h")) à \(String(format: "%.2f", disponibilite[1]).replacingOccurrences(of: ".", with: "h"))")
        }
        counter += 1
    }
    print("Points faibles : \t\(etudiant.weaknesses.isEmpty ? "Aucun" : etudiant.weaknesses.joined(separator: ", "))")
    print("Points forts : \t\t\(etudiant.strengths.isEmpty ? "Aucun" : etudiant.strengths.joined(separator: ", "))")
    print("Disponible actuellement : \(etudiant.available ? "Oui" : "Non")")
    print("\n-------------------------------------------")
}
 
/// Affiche dans la console les informations complètes d'un étudiant passé en paramètre
/// - Parameter lsStudent: liste des étudiants (référence pour la sélection)
func printStudent(student: Student) {
 
    print("\n-------------------------------------------\n")
    print("Informations de l'étudiant '\(student.last_name) \(student.first_name)' :")
    print("ID : \t\t\t\(student.id)")
    print("Nom : \t\t\t\(student.last_name)")
    print("Prénom : \t\t\(student.first_name)")
    print("Adresse email : \t\(student.email)")
    if student.telephone == "0" {
        print("Numéro de téléphone : \tNon défini")
    } else {
        if student.telephoneVisible {
            print("Numéro de téléphone : \t\(student.telephone)")
        } else {
            print("Numéro de téléphone : \tNon visible")
        }
    }
    print("Promotion & année : \t\(student.stud_class)")
    print("Rôle(s) : \t\t\(student.roles.joined(separator: ", "))")
    print("Disponibilités :")
    var counter: Int = 0
    for day: String in days {
        let disponibilite: [Double] = student.availability[counter]
        if disponibilite[0] == -1 && disponibilite[1] == -1 {
            print("- \(day) : \t\tNon disponible")
        } else {
            print("- \(day) : \t\tDe \(String(format: "%.2f", disponibilite[0]).replacingOccurrences(of: ".", with: "h")) à \(String(format: "%.2f", disponibilite[1]).replacingOccurrences(of: ".", with: "h"))")
        }
        counter += 1
    }
    print("Points faibles : \t\(student.weaknesses.isEmpty ? "Aucun" : student.weaknesses.joined(separator: ", "))")
    print("Points forts : \t\t\(student.strengths.isEmpty ? "Aucun" : student.strengths.joined(separator: ", "))")
    print("Disponible actuellement : \(student.available ? "Oui" : "Non")")
    print("\n-------------------------------------------")
}
 
/// Désactive un étudiant (le marque comme non disponible).
/// - Parameter lsStudent: liste des étudiants (référence)
func disableEtudiant(lsStudent: inout [Student]) {
    
    var etudiant: Student = findStudent(lsStudent: &lsStudent)
 
    etudiant.available = false
    lsStudent[Int(etudiant.id)] = etudiant
    print("\nL'étudiant '\(etudiant.last_name) \(etudiant.first_name)' a été désactivé avec succès !")
}
 
// ===== GESTION DES DOMAINES =====
/// Ajoute un nouveau domaine à la liste si celui-ci n'existe pas encore.
/// - Parameter lsField: liste des domaines (référence)
func addField(lsField: inout [String]) {
    var resultLine: String
    print("\nVeuillez saisir le nom du domaine à ajouter :")
    resultLine = readLineUntilNotEmpty()
    let lsFieldLowercased: [String] = lsField.map { $0.lowercased() }
    if lsFieldLowercased.contains(resultLine.lowercased()) {
        print("\nErreur : Le domaine '\(resultLine)' existe déjà.")
    } else {
        lsField.append(resultLine)
        print("\nDomaine '\(resultLine)' ajouté avec succès !")
    }
}
 
/// Supprime un domaine existant après sélection interactive.
/// - Parameter lsField: liste des domaines (référence)
func deleteField(lsField: inout [String]) {
    var resultLine: String
    var matchDomaine: Bool = false
    let lsFieldLowercased: [String] = lsField.map { $0.lowercased() }
    repeat {
        print("\nDomaines existants :")
        for domaine: String in lsField {
            print("- \(domaine)")
        }
        print("\nVeuillez saisir le nom du domaine à supprimer :")
        resultLine = readLineUntilNotEmpty().lowercased()
        if lsFieldLowercased.contains(resultLine.trimmingCharacters(in: .whitespacesAndNewlines)) {
            matchDomaine = true
        }
    } while (!matchDomaine)
 
    let indexDomaine: Array<String>.Index = lsFieldLowercased.firstIndex(of: resultLine.trimmingCharacters(in: .whitespacesAndNewlines))!
    let removedDomaine: String = lsField[indexDomaine]
    lsField.remove(at: indexDomaine)
    print("\nDomaine '\(removedDomaine)' supprimé avec succès !")
}
 
// Fonction pour afficher tous les domaines
func printFields(lsField: inout [String]) {
    print("\nListe des domaines disponible :")
    for domaine: String in lsField {
        print("- \(domaine)")
    }
}
 
 
// ===== FONCTIONS DE MISE EN RELATION =====
/// Suggère des parrains correspondant aux points faibles et disponibilités d'un filleul.
/// Recherche les parrains qui partagent un point fort utile et dont les plages horaires se recoupent.
/// - Parameter lsStudent: liste des étudiants (référence pour sélection et comparaison)
func suggestMentors(lsStudent: inout [Student]) {
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
    if !etudiant.roles.contains("Filleul") {
        print("\nL'étudiant '\(etudiant.last_name) \(etudiant.first_name)' n'est pas filleul et ne peut pas recevoir de suggestions de parrains.")
        return
    }
 
    var suggestedMentors: [Student] = []
    var matchesAllavailable: [[Int]] = []
    for pointFaible: String in etudiant.weaknesses {
        for potentielMentor: Student in lsStudent {
            if potentielMentor.roles.contains("Parrain") && potentielMentor.available &&
                potentielMentor.strengths.contains(pointFaible) && potentielMentor.id != etudiant.id &&
                !suggestedMentors.contains(where: { $0.id == potentielMentor.id }) {
                var counter: Int = 0
                var matchesavailable: [Int] = []
                for disponibilite: [Double] in potentielMentor.availability {
                    let availabilitytartEtudiant: Double = etudiant.availability[counter][0]
                    let disponibiliteEndEtudiant: Double = etudiant.availability[counter][1]
                    let availabilitytartMentor: Double = disponibilite[0]
                    let disponibiliteEndMentor: Double = disponibilite[1]
                    
                    if ((availabilitytartEtudiant != -1 && disponibiliteEndEtudiant != -1 && availabilitytartMentor != -1 && disponibiliteEndMentor != -1) &&
                    ((availabilitytartMentor <= availabilitytartEtudiant && disponibiliteEndMentor >= disponibiliteEndEtudiant) ||
                    (availabilitytartMentor <= availabilitytartEtudiant && disponibiliteEndMentor <= disponibiliteEndEtudiant && disponibiliteEndMentor > availabilitytartEtudiant) ||
                    (availabilitytartMentor >= availabilitytartEtudiant && disponibiliteEndMentor >= disponibiliteEndEtudiant && availabilitytartMentor < disponibiliteEndEtudiant) ||
                    (availabilitytartMentor >= availabilitytartEtudiant && disponibiliteEndMentor <= disponibiliteEndEtudiant))) {
                        matchesavailable.append(counter)
 
                    }
 
                    counter += 1
                }
                if !matchesavailable.isEmpty {
                    suggestedMentors.append(potentielMentor)
                    matchesAllavailable.append(matchesavailable)
                }
            }
        }
    }
 
    if suggestedMentors.isEmpty {
        print("\nAucun parrain disponible ne correspond aux besoins de l'étudiant.")
    } else {
        var index: Int = 0
        for mentor: Student in suggestedMentors {
            print("\n-------------------------------------------\n")
            print(
                "Id: \t\t\(mentor.id)\nNom: \t\t\(mentor.last_name)\nAdresse mail: \t\(mentor.email)\nPoints forts: \t\(mentor.strengths.joined(separator: ", "))\ntéléphone: \t\(mentor.telephoneVisible ? mentor.telephone : "Non visible")"
            )
            print("Jours et heures avec disponibilités correspondantes :")
            for dayIndex: Int in matchesAllavailable[index] {
                let disponibilite: [Double] = mentor.availability[dayIndex]
                print("- \(days[dayIndex]) : \tDe \(String(format: "%.2f", disponibilite[0]).replacingOccurrences(of: ".", with: "h")) à \(String(format: "%.2f", disponibilite[1]).replacingOccurrences(of: ".", with: "h"))")
            }
            index += 1
        }
        print("\n-------------------------------------------")
    }
}
 
/// Recherche d'offres correspondant à un domaine et type d'aide choisis par l'utilisateur,
/// puis filtre sur les disponibilités communes.
func searchOfferByFilters(lsStudent: inout [Student], lsOffer: inout [Offer], lsField: [String]) {
    var resultLine: String
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
 
    print("\nChoisissez le domaine de l'offre recherchée :")
    var matchDomaine: Bool = false
    repeat {
        for domaine: String in lsField {
            print("- \(domaine)")
        }
        resultLine = readLineUntilNotEmpty().lowercased()
        let lsFieldLowercased: [String] = lsField.map { $0.lowercased() }
        if lsFieldLowercased.contains(resultLine.trimmingCharacters(in: .whitespacesAndNewlines)) {
            matchDomaine = true
        }
        if !matchDomaine {
            print("Un domaine disponible doit être sélectionné :")
        }
    } while (!matchDomaine)
 
    let choixDomaine: String = resultLine
 
    print("\nChoisissez le type d'aide recherchée :")
    var matchAide: Bool = false
    repeat {
        for typeAide: String in lsHelpTypes {
            print("- \(typeAide)")
        }
        resultLine = readLineUntilNotEmpty().lowercased()
        let lsTypeAideLowercased: [String] = lsHelpTypes.map { $0.lowercased() }
        if lsTypeAideLowercased.contains(resultLine.trimmingCharacters(in: .whitespacesAndNewlines)) {
            matchAide = true
        }
        if !matchAide {
            print("Un type d'aide disponible doit être sélectionné :")
        }
    } while (!matchAide)
    let choixTypeAide: String = resultLine
    
    print("\nOffres disponibles dans le domaine '\(choixDomaine)' pour le type d'aide '\(choixTypeAide)' :")
    var foundOffers: Bool = false
    var sortedOffer: [Offer] = lsOffer
    sortedOffer.sort { $0.date > $1.date }
    for offre: Offer in sortedOffer {
        if offre.field.lowercased() == choixDomaine && offre.helpType.lowercased() == choixTypeAide {
            var matchesavailable: [Int] = []
            for dayIndex: Int in 0..<days.count {
                let disponibiliteEtudiant: [Double] = etudiant.availability[dayIndex]
                let disponibiliteOffre: [Double] = offre.student.availability[dayIndex]
                
                if ((disponibiliteEtudiant[0] != -1 && disponibiliteEtudiant[1] != -1 && disponibiliteOffre[0] != -1 && disponibiliteOffre[1] != -1) &&
                    ((disponibiliteOffre[0] <= disponibiliteEtudiant[0] && disponibiliteOffre[1] >= disponibiliteEtudiant[1]) ||
                    (disponibiliteOffre[0] <= disponibiliteEtudiant[0] && disponibiliteOffre[1] <= disponibiliteEtudiant[1] && disponibiliteOffre[1] > disponibiliteEtudiant[0]) ||
                    (disponibiliteOffre[0] >= disponibiliteEtudiant[0] && disponibiliteOffre[1] >= disponibiliteEtudiant[1] && disponibiliteOffre[0] < disponibiliteEtudiant[1]) ||
                    (disponibiliteOffre[0] >= disponibiliteEtudiant[0] && disponibiliteOffre[1] <= disponibiliteEtudiant[1]))) {
                    foundOffers = true
                    matchesavailable.append(dayIndex)
                }
            }
            if foundOffers {
                // Formatter la date de création pour une meilleure lisibilité
                let dateFormatter: DateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let formattedDate: String = dateFormatter.string(from: offre.date)
 
                print("\n-------------------------------------------\n")
                print(
                    "Id Offre: \t\t\t\(offre.id)\nDomaine: \t\t\t\(offre.field)\nType d'aide: \t\t\t\(offre.helpType)\nParrain: \t\t\t\(offre.student.last_name) \(offre.student.first_name)\nAdresse mail du parrain: \t\(offre.student.email)\nTéléphone du parrain: \t\t\(offre.student.telephoneVisible ? offre.student.telephone : "Non visible")\nDate de publication de l'offre: \(formattedDate)"
                )
                print("Jours et heures avec disponibilités correspondantes :")
                for dayIndex: Int in matchesavailable {
                    let disponibilite: [Double] = offre.student.availability[dayIndex]
                    print("- \(days[dayIndex]) : \tDe \(String(format: "%.2f", disponibilite[0]).replacingOccurrences(of: ".", with: "h")) à \(String(format: "%.2f", disponibilite[1]).replacingOccurrences(of: ".", with: "h"))")
                }
            }
        }
    }
    if !foundOffers {
        print("\nAucune offre trouvée dans le domaine '\(choixDomaine)' pour le type d'aide '\(choixTypeAide)'.")
    } else {
        print("\n-------------------------------------------")
    }
}
 
/// Recherche et affiche les demandes correspondant aux points forts et disponibilités d'un parrain.
func searchRequests(lsRequest: inout [Request], lsStudent: inout [Student]) {
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
    if !etudiant.roles.contains("Parrain") {
        print("\nL'étudiant '\(etudiant.last_name) \(etudiant.first_name)' n'est pas parrain et ne peut pas recevoir de suggestions de demandes.")
        return
    }
 
    print("\nDemandes disponibles correspondant aux points forts et disponibilités de l'étudiant '\(etudiant.last_name) \(etudiant.first_name)' :")
    var foundDemands: Bool = false
    var sortedDemands: [Request] = lsRequest
    sortedDemands.sort {
        if $0.field == $1.field {
            return $0.date > $1.date
        } else {
            return $0.field < $1.field
        }
    }
    for demande: Request in sortedDemands {
        if etudiant.strengths.contains(demande.field) {
            var matchesavailable: [Int] = []
            for dayIndex: Int in 0..<days.count {
                let disponibiliteEtudiant: [Double] = etudiant.availability[dayIndex]
                let disponibiliteDemande: [Double] = demande.student.availability[dayIndex]
                
                if ((disponibiliteEtudiant[0] != -1 && disponibiliteEtudiant[1] != -1 && disponibiliteDemande[0] != -1 && disponibiliteDemande[1] != -1) &&
                    ((disponibiliteDemande[0] <= disponibiliteEtudiant[0] && disponibiliteDemande[1] >= disponibiliteEtudiant[1]) ||
                    (disponibiliteDemande[0] <= disponibiliteEtudiant[0] && disponibiliteDemande[1] <= disponibiliteEtudiant[1] && disponibiliteDemande[1] > disponibiliteEtudiant[0]) ||
                    (disponibiliteDemande[0] >= disponibiliteEtudiant[0] && disponibiliteDemande[1] >= disponibiliteEtudiant[1] && disponibiliteDemande[0] < disponibiliteEtudiant[1]) ||
                    (disponibiliteDemande[0] >= disponibiliteEtudiant[0] && disponibiliteDemande[1] <= disponibiliteEtudiant[1]))) {
                    foundDemands = true
                    matchesavailable.append(dayIndex)
                }
            }
            if foundDemands {
                // Formatter la date de création pour une meilleure lisibilité
                let dateFormatter: DateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let formattedDate: String = dateFormatter.string(from: demande.date)
 
                print("\n-------------------------------------------\n")
                print(
                    "Id Offre: \t\t\t\(demande.id)\nDomaine: \t\t\t\(demande.field)\nNiveau: \t\t\t\(demande.level)\nDescription: \t\t\t\(demande.description)\nFilleul: \t\t\t\(demande.student.last_name) \(demande.student.first_name)\nAdresse mail du filleul: \t\(demande.student.email)\nTéléphone du parrain: \t\t\(demande.student.telephoneVisible ? demande.student.telephone : "Non visible")\nDate de publication de l'offre: \(formattedDate)"
                )
                print("Jours et heures avec disponibilités correspondantes :")
                for dayIndex: Int in matchesavailable {
                    let disponibilite: [Double] = demande.student.availability[dayIndex]
                    print("- \(days[dayIndex]) : \tDe \(String(format: "%.2f", disponibilite[0]).replacingOccurrences(of: ".", with: "h")) à \(String(format: "%.2f", disponibilite[1]).replacingOccurrences(of: ".", with: "h"))")
                }
            }
        }
    }
    if !foundDemands {
        print("\nAucune demande trouvée correspondant aux points forts et disponibilités de l'étudiant.")
    } else {
        print("\n-------------------------------------------")
    }
}
 
// ###################################################
// ################# FAIT PAR DOKAN ##################
// ###################################################
 
 
 
 
// ###################################################
// ################# FAIT PAR DANIEL #################
// ###################################################
 
 
/// Recherche binaire d'un étudiant par identifiant.
/// Divise l'espace de recherche par 2 à chaque itération (très efficace).
/// - Parameters:
///   - lsStudent: tableau trié d'étudiants
///   - studentId: identifiant recherché
/// - Returns: indice dans `lsStudent` ou -1 si non trouvé
func searchStudent(lsStudent: inout [Student], studentId: Int) -> Int {
 
    var low: Int = 0
    var high: Int = lsStudent.count - 1
    while low <= high {
        let mid: Int = low + (high - low) / 2
        if lsStudent[mid].id == studentId {
            return mid
        } else if lsStudent[mid].id > studentId {
            high = mid - 1
        } else {
            low = mid + 1
        }
    }
    return -1
}

/// Vérifie si un étudiant en doublon existe (même email ou téléphone).
func isDuplicateStudent(lsStudent: inout [Student], newStudent: inout Student) -> Bool {
    for etud: Student in lsStudent {
        if etud.email == newStudent.email || etud.telephone == newStudent.telephone {
            return true
        }
    }
    return false
}

/// Vérifie si une demande en doublon existe (même description, domaine, niveau et auteur).
func isDuplicateRequest(lsRequest: inout [Request], newRequest: inout Request) -> Bool {
    for demande: Request in lsRequest {
        if demande.description == newRequest.description && demande.field == newRequest.field && demande.level == newRequest.level && demande.student.id == newRequest.student.id {
            return true
        }
    }
    return false
}

/// Vérifie si une offre en doublon existe (même domaine, type d'aide et auteur).
func isDuplicateOffer(lsOffer: inout [Offer], newOffer: inout Offer) -> Bool {
    for offre: Offer in lsOffer {
        if offre.field == newOffer.field && offre.student.id == newOffer.student.id && offre.helpType == newOffer.helpType {
            return true
        }
    }
    return false
}
 
 
// ======================
// GESTION DES ANNONCES
/// Chaque fonction prend en tant que paramètre la reférence de la liste qui contient toutes les occurances du type manipulé, ici: Offer et Requests
// ======================
 
// ===== GESTION DES DEMANDES D'AIDE =====
/// Lance un formulaire pour créer une nouvelle demande d'aide.
func createRequest(lsRequest: inout [Request], lsStudent: inout [Student]) {
    var resultLine: String
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
    print("Choisissez le domaine demandé:")
    var i: Int = 1
    for domaine: String in etudiant.weaknesses {
        print("\(i). \(domaine)")
        i += 1
    }
 
    resultLine = readLineUntilNotEmpty()
    
    while !matchToRegex(input: resultLine, regex: "[0-9]+") {
        print("Mauvaise saisie, veuillez ressayer")
        resultLine = readLineUntilNotEmpty()
    }
 
    let choixDomaine: String = etudiant.weaknesses[Int(resultLine)! - 1]
    print("Donner la description de votre demande:")
    let description: String = readLineUntilNotEmpty()
    print("Quel est le niveau attendu?")
    var niveau: String = readLineUntilNotEmpty()
    
    while !isAlphaNumeric(niveau) {
        print("Mauvaise saisie, veuillez ressayer")
        niveau = readLineUntilNotEmpty()
    }
 
    let date: Date = Date()
 
    var newRequest: Request = Request(
            id: UInt(lsRequest.count),
            student: etudiant, field: choixDomaine, description: description, level: niveau,
            active: true, date: date)
 
    if (!isDuplicateRequest(lsRequest: &lsRequest, newRequest: &newRequest)) {
        print("Demande créée avec succès!")
        lsRequest.append(newRequest)
    } else {
        print("La demande existe déjà.")
    }
}

/// Désactive une ou plusieurs demandes d'aide de l'étudiant.
func deleteRequest(lsRequest: inout [Request], lsStudent: inout [Student]) -> Void {
 
    var resultLine: String
 
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
    
    let etudId: UInt = etudiant.id
    var templsRequestId: [UInt] = []
    var ind: Int = 1
    for demande: Request in lsRequest {
        if etudId == demande.student.id && demande.active {
            print("\(ind).")
            printRequest(request: demande)
            templsRequestId.append(demande.id)
            ind += 1
        }
    }
    
    print("Veuillez saisir l'identifiant ou les identifiants de la demande ou des demandes à supprimer:")
    print("Ex: 1,2,3")
    
    resultLine = readLineUntilNotEmpty()
    
    while !matchToRegex(input: resultLine, regex: "([0-9],?)+") {
        print("Mauvaise saisie, veuillez ressayer")
        resultLine = readLineUntilNotEmpty()
    }
    
    let lsRequestsToDeleteStr: [String] = resultLine.components(separatedBy: ",")
    var lsRequestsToDeleteInt: [UInt] = []
    for demandeIdStr: String in lsRequestsToDeleteStr {
        lsRequestsToDeleteInt.append(UInt(demandeIdStr.trimmingCharacters(in: .whitespacesAndNewlines))!)
    }
 
    for i: Int in 0..<lsRequest.count {
        for requestToDeleteId: UInt in lsRequestsToDeleteInt {
            if lsRequest[i].id == requestToDeleteId {
                lsRequest[i].active = false
                break
            } // O(n^2)
        }
    }
 
    print("Demande(s) supprimée(s)!")
}

/// Affiche les détails d'une demande d'aide.
func printRequest(request: Request) -> Void {
 
    let calendar: Calendar = Calendar.current
    let day: Int = calendar.component(.day, from: request.date)
    let month: Int = calendar.component(.month, from: request.date)
    let hour: Int = calendar.component(.hour, from: request.date)
    let minutes: Int = calendar.component(.minute, from: request.date)
    print("\tDemande id: \(request.id)")
    print("\tEtudiant id: \(request.student.id)")
    print("\tDomaine: \(request.field)")
    print("\tDescription: \(request.description)")
    print("\tNiveau: \(request.level)")
    print("\tDate: \(day)/\(month) \(hour):\(minutes)")
 
}
 
// ===== GESTION DE LA MODIFICATION DES DEMANDES D'AIDE =====
// Permet à un étudiant de modifier une demande d'aide qu'il a créée
// Un étudiant (Filleul) peut modifier son domaine demandé, le niveau, la description ou l'activer/désactiver
func modifyRequest(lsRequest: inout [Request], lsStudent: inout [Student]) {
 
    var resultLine: String
 
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
    
    let etudId: UInt = etudiant.id
    var templsRequestId: [UInt] = []
    var ind: Int = 1
    for demande: Request in lsRequest {
        if etudId == demande.student.id && demande.active {
            print("\(ind).")
            printRequest(request: demande)
            templsRequestId.append(demande.id)
            ind += 1
        }
    }
    print("Veuillez saisir la demande à modifier:")
    resultLine = readLineUntilNotEmpty()
 
    while !matchToRegex(input: resultLine, regex: "[0-9]+") {
        print("Mauvaise saisie, veuillez ressayer")
        resultLine = readLineUntilNotEmpty()
    }
    
    let demandeIdtoModify: UInt = UInt(resultLine)!
 
    for i in 0..<lsRequest.count {
        if demandeIdtoModify == lsRequest[i].id {
            print("Que voulez-vous modifier? (Une seule chose peut être modifiée)")
            print("Modifiable: domaine, description, niveau, active")
            print("Ex: domaine")
            let modifyOpt: String = readLineUntilNotEmpty()
            switch modifyOpt {
                case "domaine":
                    print("Choisissez le domaine demandé:")
 
                    var i: Int = 1
 
                    for domaine: String in etudiant.weaknesses {
                        print("\(i). \(domaine)")
                        i += 1
                    }
 
                    resultLine = readLineUntilNotEmpty()
                
                    while !matchToRegex(input: resultLine, regex: "[0-9]+") {
                        print("Mauvaise saisie, veuillez ressayer")
                        resultLine = readLineUntilNotEmpty()
                    }
 
                    let choixDomaine: String = etudiant.weaknesses[Int(resultLine)! - 1]
 
 
                    let date: Date = Date()
                    lsRequest[i].date = date
                    lsRequest[i].field = choixDomaine
                    print("Domaine modifié")
 
                case "niveau":
                
                    print("Quel est le niveau attendu?")
 
                    var niveau: String = readLineUntilNotEmpty()
                
                    while !matchToRegex(input: niveau, regex: "[0-9]+") {
                        print("Mauvaise saisie, veuillez ressayer")
                        niveau = readLineUntilNotEmpty()
                    }
                    let date: Date = Date()
                    lsRequest[i].date = date
                    lsRequest[i].level = niveau
                    print("Niveau modifié")

                case "description":
                    print("Donner la description de votre demande:")
 
                    let description: String = readLineUntilNotEmpty()
                    let date: Date = Date()
                    lsRequest[i].date = date
                    lsRequest[i].description = description
                    print("Description modifiée")
                
                // on change le champs "active" de cette annonce, soit on l'active, soit désactive
                case "active":
                    if lsRequest[i].active == true {
                        lsRequest[i].active = false
                        print("Demande désactivée")
                    } else {
                        lsRequest[i].active = true
                        let date = Date()
                        lsRequest[i].date = date
                        print("Demande activée")
                    }
 
                default:
                    print("Rien n'était sélectionné ou mauvaise réponse")
            }
        }
    }
}
 
// ===== GESTION DES OFFRES DE MENTORAT =====
/// Lance un formulaire pour créer une nouvelle offre de mentorat.
func createOffer(lsOffer: inout [Offer], lsStudent: inout [Student]) -> Void {
    var resultLine: String
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
    print("Choisissez le domaine offert:")
    var i: Int = 1
    for domaine: String in etudiant.strengths {
        print("\(i). \(domaine)")
        i += 1
    }
 
    resultLine = readLineUntilNotEmpty()
    
    while !matchToRegex(input: resultLine, regex: "[0-9]+") {
        print("Mauvaise saisie, veuillez ressayer")
        resultLine = readLineUntilNotEmpty()
    }
  
    let choixDomaine: String = etudiant.strengths[Int(resultLine)! - 1]
    print("Précisez le type d'aide proposé:")
    i = 1
    for typeAide: String in lsHelpTypes {
        print("\(i). \(typeAide)")
        i += 1
    }
    
    resultLine = readLineUntilNotEmpty()
    
    while !matchToRegex(input: resultLine, regex: "[0-9]+") {
        print("Mauvaise saisie, veuillez ressayer")
        resultLine = readLineUntilNotEmpty()
    }
 
    let typeAide: String = lsHelpTypes[Int(resultLine)!-1]
    let date: Date = Date()
    var newOffer: Offer = Offer(
        id: UInt(lsOffer.count),
        student: etudiant, field: choixDomaine, helpType: typeAide, active: true, date: date)
 
    if (!isDuplicateOffer(lsOffer: &lsOffer, newOffer: &newOffer)) {
        print("Offre créée avec succès!")
        lsOffer.append(newOffer)
    } else {
        print("L'offre existe déjà.")
    }
}

/// Désactive une ou plusieurs offres de mentorat de l'étudiant.
func deleteOffer(lsOffer: inout [Offer], lsStudent: inout [Student]) {
 
    var resultLine: String
 
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
 
    let etudId: UInt = etudiant.id
    var templsOfferId: [UInt] = []
    var ind: Int = 1
    for offre: Offer in lsOffer {
        if etudId == offre.student.id && offre.active {
            print("\(ind).")
            printOffer(offer: offre)
            templsOfferId.append(offre.id)
            ind += 1
        }
    }
    print("Veuillez saisir l'identifiant ou les identifiants de l'offre ou des offres à supprimer:")
    print("Ex: 1,2,3")
    resultLine = readLineUntilNotEmpty()
    
    while !matchToRegex(input: resultLine, regex: "([0-9],?)+") {
        print("Mauvaise saisie, veuillez ressayer")
        resultLine = readLineUntilNotEmpty()
    }
    
    let lsOffersToDeleteStr: [String] = resultLine.components(separatedBy: ",")
    var lsOffersToDeleteInt: [UInt] = []
    for offreIdStr: String in lsOffersToDeleteStr {
        lsOffersToDeleteInt.append(UInt(offreIdStr.trimmingCharacters(in: .whitespacesAndNewlines))!)
    }
 
    for i: Int in 0..<lsOffer.count {
        for offreToDeleteId: UInt in lsOffersToDeleteInt {
            if lsOffer[i].id == offreToDeleteId {
                lsOffer[i].active = false
                break
            } // O(n^2)
        }
    }
 
    print("Offre(s) supprimée(s)!")
}
/// Affiche les détails d'une offre de mentorat.
func printOffer(offer: Offer) -> Void {
    let calendar: Calendar = Calendar.current
    let day: Int = calendar.component(.day, from: offer.date)
    let month: Int = calendar.component(.month, from: offer.date)
    let hour: Int = calendar.component(.hour, from: offer.date)
    let minutes: Int = calendar.component(.minute, from: offer.date)
    print("\tOffre id: \(offer.id)")
    print("\tEtudiant id: \(offer.student.id)")
    print("\tDomaine: \(offer.field)")
    print("\tType d'aide: \(offer.helpType)")
    print("\tDate: \(day)/\(month) \(hour):\(minutes)")
 
}
 
// ===== GESTION DE LA MODIFICATION DES OFFRES D'AIDE =====
// Permet à un parrain de modifier une offre d'aide qu'il a créée
// Un étudiant (Parrain) peut modifier le domaine offert, le type d'aide ou l'activer/désactiver
func modifyOffer(lsOffer: inout [Offer], lsStudent: inout [Student]) {
    var resultLine: String
    let etudiant: Student = findStudent(lsStudent: &lsStudent)
    let etudId: UInt = etudiant.id
    var templsOfferId: [UInt] = []
    var ind: Int = 1
    for offre: Offer in lsOffer {
        if etudId == offre.student.id && offre.active {
            print("\n-------------------------------------------\n")
            print("\(ind).")
            printOffer(offer: offre)
            
            templsOfferId.append(offre.id)
            ind += 1
        }
    }
    print("\n-------------------------------------------\n")
    
    print("Veuillez saisir l'offre à modifier:")
    
    resultLine = readLineUntilNotEmpty()
    
    while !matchToRegex(input: resultLine, regex: "[0-9]+") {
        print("Mauvaise saisie, veuillez ressayer")
        resultLine = readLineUntilNotEmpty()
    }
  
    let offreIdtoModify: UInt = UInt(resultLine)!
    for i: Int in 0..<lsOffer.count {
        if offreIdtoModify == lsOffer[i].id {
            print("Que voulez-vous modifier? (Une seule chose peut être modifiée)")
            print("Modifiable: domaine, typeAide, active")
            print("Ex: domaine")
            let modifyOpt: String = readLineUntilNotEmpty()
            switch modifyOpt {
                case "domaine":
                    print("Choisissez le domaine offert:")
 
                    let etudiant: Student = lsStudent[searchStudent(lsStudent: &lsStudent, studentId: Int(resultLine)!)]
                    var i: Int = 1
 
                    for domaine: String in etudiant.strengths {
                        print("\(i). \(domaine)")
                        i += 1
                    }
 
                    resultLine = readLineUntilNotEmpty()
                
                    while !matchToRegex(input: resultLine, regex: "[0-9]+") {
                        print("Mauvaise saisie, veuillez ressayer")
                        resultLine = readLineUntilNotEmpty()
                    }
 
                    let choixDomaine: String = etudiant.strengths[Int(resultLine)! - 1]
 
 
                    let date: Date = Date()
                    lsOffer[i].date = date
                    lsOffer[i].field = choixDomaine
                    print("Domaine modifié")
 
                case "typeAide":
                    print("Précisez le type d'aide proposé:")
                    var i: Int = 1
                    for typeAide: String in lsHelpTypes {
                        print("\(i). \(typeAide)")
                        i += 1
                    }
    
                    resultLine = readLineUntilNotEmpty()
                
                    while !matchToRegex(input: resultLine, regex: "[0-9]+") {
                        print("Mauvaise saisie, veuillez ressayer")
                        resultLine = readLineUntilNotEmpty()
                    }
 
                    let typeAide: String = lsHelpTypes[Int(resultLine)!-1]
 
                    let date: Date = Date()
                    lsOffer[i].date = date
                    lsOffer[i].helpType = typeAide
                    print("Type d'aide modifié")
                
                
                // on change le champs "active" de cette annonce, soit on l'active, soit désactive
                case "active":
                    if lsOffer[i].active == true {
                        lsOffer[i].active = false
                        print("Offre désactivée")
                    } else {
                        lsOffer[i].active = true
                        let date: Date = Date()
                        lsOffer[i].date = date
                        print("Offre activée")
                    }
 
                default:
                    print("Rien n'était sélectionné ou mauvaise réponse")
            }
        }
    }
}
 
// ===== FONCTIONS D'AFFICHAGE ET STATISTIQUES =====
/// Affiche des statistiques sur les offres et demandes pour un domaine choisi.
func printStats(lsRequest: inout [Request], lsOffer: inout [Offer], lsField: [String]) {
    print("Veuillez choisir un domaine pour voir ses statistiques:")
    var i: Int = 1
    for domaine: String in lsField {
        print("\(i). \(domaine)")
        i += 1
    }
    print("Ex: Mathématiques")
    var domaine: String = readLineUntilNotEmpty().lowercased()
 
    while !isAlphaNumeric(domaine) {
        print("Mauvaise saisie, veuillez ressayer")
        domaine = readLineUntilNotEmpty().lowercased()
    }
    var oi: Int = 0
    for offre: Offer in lsOffer {
        if domaine == offre.field.lowercased() {
            oi += 1
        }
    }
    print("Offres avec ce domaine: \(oi)")
    var di: Int = 0
    for demande: Request in lsRequest {
        if domaine == demande.field.lowercased() {
            di += 1
        }
    }
    print("Demandes avec ce domaine: \(di)")
    print("Total d'annonces avec ce domaine: \(di+oi)")
}

/// Affiche les domaines en tension (décalage offres/demandes >= 5).
func printStatsTension(lsRequest: inout [Request], lsOffer: inout [Offer], lsField: [String]) {
    print("Domaines \"en tension\"")
    var domaineStats: [String: (demandes: Int, offres: Int)] = [:]
    for domaine: String in lsField {
        domaineStats[domaine] = (0, 0)
    }
    for demande: Request in lsRequest {
        domaineStats[demande.field]!.demandes += 1
    }
    for offre: Offer in lsOffer {
        domaineStats[offre.field]!.offres += 1
    }
    let tensionDif: Int = 5 // s'il y a une différence de 5 annonces entre les offres et les demandes, on marque le domaine "en tension"
    for (domaine, stats) in domaineStats {
        if stats.offres - stats.demandes >= tensionDif {
            print("\tPlus d'offres que de demandes dans le domaine de \(domaine)")
        } else if stats.demandes - stats.offres >= tensionDif {
            print("\tPlus de demandes que d'offres dans le domaine de \(domaine)")
        }
    }
}

/// Affiche toutes les offres de mentorat avec leurs détails.
func printAllOffers(lsOffer: inout [Offer]) {
    for offer: Offer in lsOffer {
        printStudent(student: offer.student)
        printOffer(offer: offer)
        print("\n\n")
    }
}

/// Affiche toutes les demandes d'aide avec leurs détails.
func printAllRequests(lsRequest: inout [Request]) {
    for request: Request in lsRequest {
        printStudent(student: request.student)
        printRequest(request: request)
        print("\n\n")
    }
}
 
// ===== FONCTIONS UTILITAIRES POUR L'ENTRÉE UTILISATEUR =====
/// Lit une ligne depuis l'entrée utilisateur jusqu'à ce qu'elle soit valide (non vide).
func readLineUntilNotEmpty() -> String {
    var input: String? = nil // Variable optionnelle pour stocker l'entrée
    input = readLine() // Lit une ligne depuis l'entrée standard
    // Boucle tant que l'entrée est invalide (vide, nulle, ou seulement des espaces)
    while inputInvalid(input: input) {
        print("Saisie invalide. Veuillez ressayer.") // Affiche un message d'erreur
        input = readLine() // Redemande une entrée
    }
    // Retourne l'entrée valide en supprimant les espaces avant et après
    return input!.trimmingCharacters(in: .whitespacesAndNewlines)
}
 
/// Vérifie si une entrée est invalide (nil, vide ou seulement espaces).
func inputInvalid(input: String?) -> Bool {
    // Retourne true si:
    // - input est nil (aucune entrée)
    // - input est une chaîne vide
    // - input ne contient que des espaces (après suppression des espaces)
    return input == nil || input!.isEmpty || input!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

/// Vérifie si une chaîne ne contient que des caractères alphanumériques.
func isAlphaNumeric(_ string: String) -> Bool {
    let allowedChars: CharacterSet = CharacterSet.alphanumerics
    return string.unicodeScalars.allSatisfy({ allowedChars.contains($0) })
}
 
 
 
// ###################################################
// ################# FAIT PAR DANIEL #################
// ###################################################
 
 
@main
/// Point d'entrée principal de l'application.
/// Initialise les données de test et lance la boucle interactive du menu.
struct projet {
    static func main() throws {
        
        // ===== DONNÉES FICTIVES POUR TESTER L'APPLICATION =====
 
        var lsField: [String] = [
            "Mathématiques", "Physique", "Chimie", "Biologie", "Informatique", "Anglais", "Espagnol", "Histoire",
            "Géographie", "Littérature", "Philosophie", "Economie", "Droit",
        ]
        
        // ---- ÉTUDIANT 1: Marie Dupont (Filleul) ----
        let etudiant1: Student = Student(
            id: 0,
            last_name: "Dupont",
            first_name: "Marie",
            email: "marie.dupont@uppa.fr",
            telephone: "0612345678",
            telephoneVisible: true,
            stud_class: "Terminale 1",
            roles: ["Filleul"],
            availability: [[14.00, 17.00], [-1, -1], [10.00, 12.00], [-1, -1], [15.00, 18.00], [-1, -1], [-1, -1]],
            weaknesses: ["Mathématiques", "Physique", "Informatique"],
            strengths: [],
            available: true)
        
        // ---- ÉTUDIANT 2: Jean Martin (Parrain) ----
        let etudiant2: Student = Student(
            id: 1,
            last_name: "Martin",
            first_name: "Jean",
            email: "jean.martin@uppa.fr",
            telephone: "0687654321",
            telephoneVisible: false,
            stud_class: "Terminale 2",
            roles: ["Parrain"],
            availability: [[16.00, 18.00], [14.00, 16.00], [09.00, 11.00], [-1, -1], [-1, -1], [10.00, 14.00], [-1, -1]],
            weaknesses: [],
            strengths: ["Mathématiques", "Informatique", "Biologie"],
            available: true)
        
        // ---- ÉTUDIANT 3: Sophie Bernard (Filleul + Parrain) ----
        let etudiant3: Student = Student(
            id: 2,
            last_name: "Bernard",
            first_name: "Sophie",
            email: "sophie.bernard@uppa.fr",
            telephone: "0",
            telephoneVisible: false,
            stud_class: "Terminale 1",
            roles: ["Filleul", "Parrain"],
            availability: [[17.00, 19.00], [-1, -1], [15.00, 17.30], [14.00, 16.00], [10.00, 12.00], [-1, -1], [14.00, 17.00]],
            weaknesses: ["Chimie", "Biologie"],
            strengths: ["Littérature", "Histoire"],
            available: true)
        
        // ---- ÉTUDIANT 4: Carlos Garcia (Parrain) ----
        let etudiant4: Student = Student(
            id: 3,
            last_name: "Garcia",
            first_name: "Carlos",
            email: "carlos.garcia@uppa.fr",
            telephone: "0698765432",
            telephoneVisible: true,
            stud_class: "Terminale 2",
            roles: ["Parrain"],
            availability: [[12.00, 17.00], [16.00, 18.00], [-1, -1], [-1, -1], [-1, -1], [14.00, 16.00], [-1, -1]],
            weaknesses: [],
            strengths: ["Physique", "Chimie", "Informatique"],
            available: true)
        
        // ---- Liste des Étudiants ----
        var lsStudent: [Student] = [etudiant1, etudiant2, etudiant3, etudiant4]
        
        // Demandes d'aide initiales (créées par des filleuls)
        let demande1: Request = Request(id: 0, student: etudiant1, field: "Mathématiques", description: "Aide pour comprendre les dérivées et l'intégration", level: "Intermédiaire", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 7, day: 12, hour: 11, minute: 36, second: 18).date!)
        let demande2: Request = Request(id: 1, student: etudiant1, field: "Physique", description: "Besoin d'aide pour la mécanique quantique", level: "Avancé", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 8, day: 29, hour: 23, minute: 10, second: 36).date!)
        let demande3: Request = Request(id: 2, student: etudiant3, field: "Chimie", description: "Aide pour les équations de réaction", level: "Débutant", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 2, day: 26, hour: 13, minute: 39, second: 28).date!)
        let demande4: Request = Request(id: 3, student: etudiant1, field: "Physique", description: "Besoin d'aide pour la mécanique quantique", level: "Avancé", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 10, day: 23, hour: 18, minute: 29, second: 10).date!)
        
        var lsRequest: [Request] = [demande1, demande2, demande3, demande4]
        
        // Offres de mentorat initiales (créées par des parrains)
        let offre1: Offer = Offer(id: 0, student: etudiant2, field: "Mathématiques", helpType: "Leçon complète", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 5, day: 16, hour: 10, minute: 27, second: 10).date!)
        let offre2: Offer = Offer(id: 1, student: etudiant2, field: "Informatique", helpType: "Explication d'un point", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 8, day: 2, hour: 17, minute: 20, second: 56).date!)
        let offre3: Offer = Offer(id: 2, student: etudiant4, field: "Physique", helpType: "Résolution d'exercices", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 9, day: 30, hour: 19, minute: 41, second: 52).date!)
        let offre4: Offer = Offer(id: 3, student: etudiant4, field: "Chimie", helpType: "Leçon complète", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 8, day: 16, hour: 16, minute: 51, second: 29).date!)
        let offre5: Offer = Offer(id: 4, student: etudiant3, field: "Littérature", helpType: "Explication d'un point", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 2, day: 19, hour: 12, minute: 40, second: 25).date!)
        let offre6: Offer = Offer(id: 5, student: etudiant4, field: "Informatique", helpType: "Explication d'un point", active: true, date: DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2025, month: 8, day: 18, hour: 20, minute: 48, second: 13).date!)
        
        var lsOffer: [Offer] = [offre1, offre2, offre3, offre4, offre5, offre6]
        
        // ===== BOUCLE PRINCIPALE (Menu principal) =====
        var q: Bool = false // Variable de contrôle pour quitter l'application
 
 
        // ---- Boucle jusqu'au choix de quitter ----
        repeat {
            // Affiche le menu avec toutes les commandes disponibles
            print("\n\n\n--------------------------")
            print("Liste des commandes disponibles:")
            print("\n")
            print("-------- Création --------")
            print("ce\t\tcréer étudiant") // DOKAN
            print("co\t\tcréer offre") // DANIEL
            print("cd\t\tcréer demande") // DANIEL
            print("cdo\t\tcréer domaine") // DOKAN
            print("\n")
            print("------ Modification ------")
            print("me\t\tmodifier étudiant") // DOKAN
            print("mo\t\tmodifier offre") // DANIEL
            print("md\t\tmodifier demande") // DANIEL
            print("\n")
            print("------ Suppression -------")
            print("se\t\tsupprimer étudiant") // DOKAN
            print("so\t\tsupprimer offre") // DANIEL
            print("sd\t\tsupprimer demande") // DANIEL
            print("sdo\t\tsupprimer domaine") // DOKAN
            print("\n")
            print("------- Affichage --------")
            print("ae\t\tafficher étudiant") // DOKAN
            print("ao\t\tafficher offres") // DANIEL
            print("ad\t\tafficher demandes") // DANIEL
            print("ado\t\tafficher domaines") // DOKAN
            print("\n")
            print("------ Statistiques ------")
            print("as\t\tafficher stats") // DANIEL
            print("at\t\tafficher domaines en tension") // DANIEL
            print("\n")
            print("----- Fonctionnalités ----")
            print("sm\t\tsuggérer mentors") // DOKAN
            print("ro\t\trechercher offres") // DOKAN
            print("rd\t\trechercher demandes") // DOKAN
            print("\n")
            print("-------- Quitter ---------")
            print("q\t\tquitter")
            print("\n")
            print("Choisissez la commande:")
 
            let resultLine: String = readLineUntilNotEmpty() // Récupère la commande de l'utilisateur
            
            // Sélectionne la fonction à exécuter selon la commande
            switch resultLine {
                
                // ---- COMMANDES DE CRÉATION ----
                case "ce":
                    print("\n\n\nCréation de l'étudiant...")
                    createStudent(lsStudent: &lsStudent, lsField: lsField) // Lance le formulaire de création
                case "co":
                    print("\n\n\nCréation de l'offre...")
                    createOffer(lsOffer: &lsOffer, lsStudent: &lsStudent)
                case "cd":
                    print("\n\n\nCréation de la demande...")
                    createRequest(lsRequest: &lsRequest, lsStudent: &lsStudent)
                case "cdo":
                    print("\n\n\nCréation du domaine...")
                    addField(lsField: &lsField) // Ajoute un nouveau domaine
                
                // ---- COMMANDES DE MODIFICATION ----
                case "me":
                    print("\n\n\nModification de l'étudiant...")
                    modifyStudent(lsStudent: &lsStudent, lsField: lsField)
                case "mo":
                    print("\n\n\nModifier une offre...")
                    modifyOffer(lsOffer: &lsOffer, lsStudent: &lsStudent)
                case "md":
                    print("\n\n\nModifier une demande...")
                    modifyRequest(lsRequest: &lsRequest, lsStudent: &lsStudent)
                
                // ---- COMMANDES DE SUPPRESSION ----
                case "se":
                    print("\n\n\nDésactivation de l'étudiant...")
                    disableEtudiant(lsStudent: &lsStudent)
                case "so":
                    print("\n\n\nSupprimer une offre...")
                    deleteOffer(lsOffer: &lsOffer, lsStudent: &lsStudent)
                case "sd":
                    print("\n\n\nSupprimer une demande...")
                    deleteRequest(lsRequest: &lsRequest, lsStudent: &lsStudent)
                case "sdo":
                    print("\n\n\nSuppression du domaine...")
                    deleteField(lsField: &lsField) // Supprime un domaine existant
                
                // ---- COMMANDES D'AFFICHAGE ----
                case "ae":
                    print("\n\n\nAffichage d'un étudiant...")
                    printStudent(lsStudent: &lsStudent) // Affiche un étudiant
                case "ao":
                    print("\n\n\nAffichage des offres...")
                    printAllOffers(lsOffer: &lsOffer)
                case "ad":
                    print("\n\n\nAffichage des demandes...")
                    printAllRequests(lsRequest: &lsRequest)
                case "ado":
                    print("\n\n\nAffichage des domaines...")
                    printFields(lsField: &lsField) // Affiche les domaines disponibles
 
                // ---- COMMANDES DE STATISTIQUES ----
                case "as":
                    print("\n\n\nAffichage des statistiques...")
                    printStats(lsRequest: &lsRequest, lsOffer: &lsOffer, lsField: lsField) // Affiche les stats d'un domaine
                case "at":
                    print("\n\n\nAffichage des domaines en tension...")
                    printStatsTension(lsRequest: &lsRequest, lsOffer: &lsOffer, lsField: lsField) // Identifie les déséquilibres
 
                // ---- COMMANDES DE FONCTIONNALITÉS ----
                case "sm":
                    print("\n\n\nSuggestion de mentors...")
                    suggestMentors(lsStudent: &lsStudent)
                case "ro":
                    print("\n\n\nRecherche d'offres...")
                    searchOfferByFilters(lsStudent: &lsStudent, lsOffer: &lsOffer, lsField: lsField)
                case "rd":
                    print("\n\n\nRecherche de demandes...")
                    searchRequests(lsRequest: &lsRequest, lsStudent: &lsStudent)
 
                // ---- QUITTER L'APPLICATION ----
                case "q":
                    print("Déconnexion...")
                    q = true
                
                // ---- COMMANDE NON RECONNUE ----
                default:
                    print("Commande non reconnue, réessayez")
            }
        } while !q // Continue jusqu'à ce que l'utilisateur choisisse de quitter
    }
}