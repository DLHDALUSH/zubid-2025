package com.zubid.app.ui.activity

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.zubid.app.R
import com.zubid.app.databinding.ActivityHelpBinding
import com.zubid.app.ui.adapter.HelpItemAdapter
import com.zubid.app.util.LocaleHelper

data class HelpItem(
    val title: String,
    val description: String,
    val action: HelpAction
)

enum class HelpAction {
    FAQ,
    CONTACT_SUPPORT,
    USER_GUIDE,
    TERMS_OF_SERVICE,
    PRIVACY_POLICY,
    REPORT_BUG,
    FEATURE_REQUEST,
    ABOUT
}

class HelpActivity : AppCompatActivity() {

    private lateinit var binding: ActivityHelpBinding
    private lateinit var helpAdapter: HelpItemAdapter

    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityHelpBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupToolbar()
        setupRecyclerView()
        loadHelpItems()
    }

    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
        supportActionBar?.apply {
            setDisplayHomeAsUpEnabled(true)
            setDisplayShowHomeEnabled(true)
            title = getString(R.string.help_support)
        }
        
        binding.toolbar.setNavigationOnClickListener {
            finish()
        }
    }

    private fun setupRecyclerView() {
        helpAdapter = HelpItemAdapter { helpItem ->
            handleHelpItemClick(helpItem)
        }
        
        binding.recyclerView.apply {
            layoutManager = LinearLayoutManager(this@HelpActivity)
            adapter = helpAdapter
        }
    }

    private fun loadHelpItems() {
        val helpItems = listOf(
            HelpItem(
                title = getString(R.string.frequently_asked_questions),
                description = getString(R.string.faq_description),
                action = HelpAction.FAQ
            ),
            HelpItem(
                title = getString(R.string.user_guide),
                description = getString(R.string.user_guide_description),
                action = HelpAction.USER_GUIDE
            ),
            HelpItem(
                title = getString(R.string.contact_support),
                description = getString(R.string.contact_support_description),
                action = HelpAction.CONTACT_SUPPORT
            ),
            HelpItem(
                title = getString(R.string.report_bug),
                description = getString(R.string.report_bug_description),
                action = HelpAction.REPORT_BUG
            ),
            HelpItem(
                title = getString(R.string.feature_request),
                description = getString(R.string.feature_request_description),
                action = HelpAction.FEATURE_REQUEST
            ),
            HelpItem(
                title = getString(R.string.terms_of_service),
                description = getString(R.string.terms_description),
                action = HelpAction.TERMS_OF_SERVICE
            ),
            HelpItem(
                title = getString(R.string.privacy_policy),
                description = getString(R.string.privacy_description),
                action = HelpAction.PRIVACY_POLICY
            ),
            HelpItem(
                title = getString(R.string.about_app),
                description = getString(R.string.about_description),
                action = HelpAction.ABOUT
            )
        )
        
        helpAdapter.submitList(helpItems)
    }

    private fun handleHelpItemClick(helpItem: HelpItem) {
        when (helpItem.action) {
            HelpAction.FAQ -> showFAQ()
            HelpAction.CONTACT_SUPPORT -> contactSupport()
            HelpAction.USER_GUIDE -> showUserGuide()
            HelpAction.TERMS_OF_SERVICE -> openWebPage("https://zubid.app/terms")
            HelpAction.PRIVACY_POLICY -> openWebPage("https://zubid.app/privacy")
            HelpAction.REPORT_BUG -> reportBug()
            HelpAction.FEATURE_REQUEST -> requestFeature()
            HelpAction.ABOUT -> showAbout()
        }
    }

    private fun showFAQ() {
        // TODO: Implement FAQ screen or open FAQ web page
        openWebPage("https://zubid.app/faq")
    }

    private fun contactSupport() {
        val intent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:support@zubid.app")
            putExtra(Intent.EXTRA_SUBJECT, "ZUBID Support Request")
            putExtra(Intent.EXTRA_TEXT, "Please describe your issue or question:")
        }
        
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        } else {
            Toast.makeText(this, "No email app found", Toast.LENGTH_SHORT).show()
        }
    }

    private fun showUserGuide() {
        // TODO: Implement user guide screen or open guide web page
        openWebPage("https://zubid.app/guide")
    }

    private fun reportBug() {
        val intent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:bugs@zubid.app")
            putExtra(Intent.EXTRA_SUBJECT, "ZUBID Bug Report")
            putExtra(Intent.EXTRA_TEXT, "Bug Description:\n\nSteps to Reproduce:\n\nExpected Behavior:\n\nActual Behavior:\n\nDevice Info: Android ${android.os.Build.VERSION.RELEASE}")
        }
        
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        } else {
            Toast.makeText(this, "No email app found", Toast.LENGTH_SHORT).show()
        }
    }

    private fun requestFeature() {
        val intent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:features@zubid.app")
            putExtra(Intent.EXTRA_SUBJECT, "ZUBID Feature Request")
            putExtra(Intent.EXTRA_TEXT, "Feature Description:\n\nWhy is this feature needed:\n\nHow should it work:")
        }
        
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        } else {
            Toast.makeText(this, "No email app found", Toast.LENGTH_SHORT).show()
        }
    }

    private fun showAbout() {
        // TODO: Implement about dialog or screen
        Toast.makeText(this, "ZUBID v1.0.0\nAuction Bidding Platform", Toast.LENGTH_LONG).show()
    }

    private fun openWebPage(url: String) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        } else {
            Toast.makeText(this, "No browser app found", Toast.LENGTH_SHORT).show()
        }
    }
}
