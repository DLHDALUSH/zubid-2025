package com.zubid.app.ui.activity

import android.os.Bundle
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.cardview.widget.CardView
import androidx.lifecycle.lifecycleScope
import com.zubid.app.R
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.local.SessionManager
import com.zubid.app.util.LocaleHelper
import kotlinx.coroutines.launch

class PaymentActivity : AppCompatActivity() {

    private lateinit var btnBack: ImageButton
    private lateinit var imgProduct: ImageView
    private lateinit var tvProductName: TextView
    private lateinit var tvProductPrice: TextView
    private lateinit var cardStripe: CardView
    private lateinit var cardFib: CardView
    private lateinit var cardGooglePay: CardView
    private lateinit var cardZainCash: CardView
    private lateinit var cardCod: CardView
    private lateinit var rbStripe: RadioButton
    private lateinit var rbFib: RadioButton
    private lateinit var rbGooglePay: RadioButton
    private lateinit var rbZainCash: RadioButton
    private lateinit var rbCod: RadioButton
    private lateinit var layoutDelivery: LinearLayout
    private lateinit var etAddress: EditText
    private lateinit var etCity: EditText
    private lateinit var etPhone: EditText
    private lateinit var etNotes: EditText
    private lateinit var tvTotal: TextView
    private lateinit var btnPay: Button
    private lateinit var progressBar: ProgressBar

    private lateinit var sessionManager: SessionManager
    private var selectedMethod: PaymentMethod = PaymentMethod.STRIPE
    private var productName: String = ""
    private var productPrice: Double = 0.0
    private var auctionId: String = ""
    private var invoiceId: Int? = null
    private var qrCodeUrl: String? = null
    private var isBuyNow: Boolean = false

    enum class PaymentMethod { STRIPE, FIB, GOOGLE_PAY, ZAINCASH, COD }

    override fun attachBaseContext(newBase: android.content.Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_payment)

        sessionManager = SessionManager(this)

        // Get intent extras - handle both old and new parameter names
        productName = intent.getStringExtra("product_name")
            ?: intent.getStringExtra("auction_title")
            ?: "Product"
        productPrice = intent.getDoubleExtra("product_price", 0.0)
            .takeIf { it > 0.0 } ?: intent.getDoubleExtra("amount", 0.0)
        auctionId = intent.getStringExtra("auction_id") ?: ""
        invoiceId = intent.getIntExtra("invoice_id", -1).takeIf { it > 0 }
        qrCodeUrl = intent.getStringExtra("qr_code_url")
        isBuyNow = intent.getBooleanExtra("is_buy_now", false)

        initViews()
        setupListeners()
        displayProductInfo()
    }

    private fun initViews() {
        btnBack = findViewById(R.id.btnBack)
        imgProduct = findViewById(R.id.imgProduct)
        tvProductName = findViewById(R.id.tvProductName)
        tvProductPrice = findViewById(R.id.tvProductPrice)
        cardStripe = findViewById(R.id.cardStripe)
        cardFib = findViewById(R.id.cardFib)
        cardGooglePay = findViewById(R.id.cardGooglePay)
        cardZainCash = findViewById(R.id.cardZainCash)
        cardCod = findViewById(R.id.cardCod)
        rbStripe = findViewById(R.id.rbStripe)
        rbFib = findViewById(R.id.rbFib)
        rbGooglePay = findViewById(R.id.rbGooglePay)
        rbZainCash = findViewById(R.id.rbZainCash)
        rbCod = findViewById(R.id.rbCod)
        layoutDelivery = findViewById(R.id.layoutDelivery)
        etAddress = findViewById(R.id.etAddress)
        etCity = findViewById(R.id.etCity)
        etPhone = findViewById(R.id.etPhone)
        etNotes = findViewById(R.id.etNotes)
        tvTotal = findViewById(R.id.tvTotal)
        btnPay = findViewById(R.id.btnPay)
        progressBar = findViewById(R.id.progressBar)
    }

    private fun setupListeners() {
        btnBack.setOnClickListener { finish() }

        cardStripe.setOnClickListener { selectPaymentMethod(PaymentMethod.STRIPE) }
        cardFib.setOnClickListener { selectPaymentMethod(PaymentMethod.FIB) }
        cardGooglePay.setOnClickListener { selectPaymentMethod(PaymentMethod.GOOGLE_PAY) }
        cardZainCash.setOnClickListener { selectPaymentMethod(PaymentMethod.ZAINCASH) }
        cardCod.setOnClickListener { selectPaymentMethod(PaymentMethod.COD) }

        rbStripe.setOnClickListener { selectPaymentMethod(PaymentMethod.STRIPE) }
        rbFib.setOnClickListener { selectPaymentMethod(PaymentMethod.FIB) }
        rbGooglePay.setOnClickListener { selectPaymentMethod(PaymentMethod.GOOGLE_PAY) }
        rbZainCash.setOnClickListener { selectPaymentMethod(PaymentMethod.ZAINCASH) }
        rbCod.setOnClickListener { selectPaymentMethod(PaymentMethod.COD) }

        btnPay.setOnClickListener { processPayment() }
    }

    private fun displayProductInfo() {
        tvProductName.text = productName
        tvProductPrice.text = String.format("$%.2f", productPrice)
        tvTotal.text = String.format("$%.2f", productPrice)
    }

    private fun selectPaymentMethod(method: PaymentMethod) {
        selectedMethod = method
        rbStripe.isChecked = method == PaymentMethod.STRIPE
        rbFib.isChecked = method == PaymentMethod.FIB
        rbGooglePay.isChecked = method == PaymentMethod.GOOGLE_PAY
        rbZainCash.isChecked = method == PaymentMethod.ZAINCASH
        rbCod.isChecked = method == PaymentMethod.COD

        // Show delivery fields for COD
        layoutDelivery.visibility = if (method == PaymentMethod.COD) View.VISIBLE else View.GONE

        // Update button text
        btnPay.text = when (method) {
            PaymentMethod.STRIPE -> getString(R.string.pay_now)
            PaymentMethod.FIB -> getString(R.string.pay_now)
            PaymentMethod.GOOGLE_PAY -> getString(R.string.pay_with_google)
            PaymentMethod.ZAINCASH -> getString(R.string.pay_now)
            PaymentMethod.COD -> getString(R.string.confirm)
        }
    }

    private fun processPayment() {
        when (selectedMethod) {
            PaymentMethod.STRIPE -> processStripePayment()
            PaymentMethod.FIB -> processFibPayment()
            PaymentMethod.GOOGLE_PAY -> processGooglePayPayment()
            PaymentMethod.ZAINCASH -> processZainCashPayment()
            PaymentMethod.COD -> processCodPayment()
        }
    }

    private fun processStripePayment() {
        showLoading(true)
        lifecycleScope.launch {
            try {
                // TODO: Integrate Stripe SDK
                // For now, simulate payment and mark as paid in backend
                processPaymentWithBackend("stripe")
            } catch (e: Exception) {
                android.util.Log.e("PaymentActivity", "Stripe payment error", e)
                showLoading(false)
                Toast.makeText(this@PaymentActivity, "Payment failed: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun processFibPayment() {
        showLoading(true)
        lifecycleScope.launch {
            try {
                // TODO: Integrate FIB payment
                processPaymentWithBackend("fib")
            } catch (e: Exception) {
                android.util.Log.e("PaymentActivity", "FIB payment error", e)
                showLoading(false)
                Toast.makeText(this@PaymentActivity, "Payment failed: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun processGooglePayPayment() {
        showLoading(true)
        lifecycleScope.launch {
            try {
                // TODO: Integrate Google Pay SDK
                processPaymentWithBackend("google_pay")
            } catch (e: Exception) {
                android.util.Log.e("PaymentActivity", "Google Pay payment error", e)
                showLoading(false)
                Toast.makeText(this@PaymentActivity, "Payment failed: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun processZainCashPayment() {
        showLoading(true)
        lifecycleScope.launch {
            try {
                // TODO: Integrate ZainCash API
                processPaymentWithBackend("zaincash")
            } catch (e: Exception) {
                android.util.Log.e("PaymentActivity", "ZainCash payment error", e)
                showLoading(false)
                Toast.makeText(this@PaymentActivity, "Payment failed: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun processCodPayment() {
        if (!validateDeliveryInfo()) return
        showLoading(true)
        lifecycleScope.launch {
            try {
                processPaymentWithBackend("cod", getDeliveryInfo())
            } catch (e: Exception) {
                android.util.Log.e("PaymentActivity", "COD payment error", e)
                showLoading(false)
                Toast.makeText(this@PaymentActivity, "Order failed: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
    }

    private suspend fun processPaymentWithBackend(paymentMethod: String, deliveryInfo: Map<String, String>? = null) {
        try {
            // For now, simulate successful payment
            // TODO: Integrate with actual payment backend API
            kotlinx.coroutines.delay(2000) // Simulate network delay

            showLoading(false)
            showSuccess()

        } catch (e: Exception) {
            showLoading(false)
            throw e
        }
    }

    private fun getDeliveryInfo(): Map<String, String> {
        return mapOf(
            "address" to etAddress.text.toString(),
            "city" to etCity.text.toString(),
            "phone" to etPhone.text.toString(),
            "notes" to etNotes.text.toString()
        )
    }

    private fun validateDeliveryInfo(): Boolean {
        if (etAddress.text.isNullOrBlank()) {
            etAddress.error = "Required"; return false
        }
        if (etCity.text.isNullOrBlank()) {
            etCity.error = "Required"; return false
        }
        if (etPhone.text.isNullOrBlank()) {
            etPhone.error = "Required"; return false
        }
        return true
    }

    private fun showLoading(show: Boolean) {
        progressBar.visibility = if (show) View.VISIBLE else View.GONE
        btnPay.isEnabled = !show
    }

    private fun showSuccess() {
        Toast.makeText(this, getString(R.string.payment_success), Toast.LENGTH_LONG).show()
        setResult(RESULT_OK)
        finish()
    }
}

