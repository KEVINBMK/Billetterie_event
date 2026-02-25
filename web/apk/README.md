# APK Android pour téléchargement depuis le site

Après avoir construit l'APK release, copiez-le ici pour qu'il soit servi par le site web.

## Firebase Hosting (plan Spark)

Sur le plan gratuit, Firebase **n’autorise pas** les fichiers exécutables (.apk). Le lien « Télécharger l’app » ne peut donc pas pointer vers votre domaine.

**Solution :** hébergez l’APK ailleurs et mettez l’URL dans le code :

1. **Google Drive**  
   - Uploadez `likita-event.apk`.  
   - Clic droit → Partager → « Tout le monde avec le lien ».  
   - Copiez le lien (ex. `https://drive.google.com/file/d/ABC123xyz/view?usp=sharing`).  
   - L’ID du fichier est la partie `ABC123xyz`.  
   - Lien direct pour téléchargement :  
     `https://drive.google.com/uc?export=download&id=ABC123xyz`

2. **Dans le projet**  
   - Ouvrez `lib/core/constants/app_constants.dart`.  
   - Remplacez `kApkDownloadUrl = ''` par :  
     `kApkDownloadUrl = 'https://drive.google.com/uc?export=download&id=VOTRE_ID';`

3. Rebuild web et redéployez.

## Si vous hébergez le site ailleurs (sans cette limite)

1. Construire l’APK : `flutter build apk --release`
2. Copier dans ce dossier : exécuter `copy_apk.bat` à la racine du projet.
3. Reconstruire le site : `flutter build web`
4. Déployer le contenu de `build/web` (avec le dossier `apk/`).  
   Le lien `/apk/likita-event.apk` fonctionnera et vous pouvez laisser `kApkDownloadUrl` vide.
