package org.equalitie.ouisync

import androidx.test.rule.ActivityTestRule
import dev.flutter.plugins.integration_test.FlutterTestRunner
import org.junit.Rule
import org.junit.runner.RunWith

@RunWith(FlutterTestRunner::class)
class MainActivityTest {
    @Rule
    @JvmField
    val rule = ActivityTestRule(
        MainActivity::class.java,
        /*initialTouchMode =*/ true,
        /*launchActivity =*/ false,
    )
}
