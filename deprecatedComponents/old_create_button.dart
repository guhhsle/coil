/*
class CreatePlaylist extends StatelessWidget {
  const CreatePlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    if (pf['grid'] == 0) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: l['Create a playlist'],
          onPressed: () async {
            String name = await getInput('', hintText: 'Name');
            Playlist.fromString(name).create();
          },
        ),
      );
    } else {
      double width = MediaQuery.of(context).size.width / (pf['grid'] == 1 ? 1.2 : (pf['grid'] + 0.5));
      return SizedBox(
        height: pf['grid'] == 1 ? (width / (16 / 9)) : width,
        width: width,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            String name = await getInput('', hintText: 'Name');
            Playlist.fromString(name).create();
          },
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }
  }
}
*/
