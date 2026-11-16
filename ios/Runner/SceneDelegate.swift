import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    // Universal links while the app is running. With scenes, iOS calls this instead of
    // AppDelegate's application(_:continue:restorationHandler:).
    override func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        super.scene(scene, continue: userActivity)
        handleUserActivity(userActivity)
    }

    // Universal links that launched the app. They arrive in the connection options, not in
    // application(_:continue:restorationHandler:).
    override func scene(_ scene: UIScene,
                        willConnectTo session: UISceneSession,
                        options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        connectionOptions.userActivities.forEach(handleUserActivity)
    }

    private func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else {
            return
        }

        (UIApplication.shared.delegate as? AppDelegate)?.handleUniversalLink(url)
    }
}
