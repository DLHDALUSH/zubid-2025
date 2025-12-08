package com.zubid.app.ui.activity

import android.os.Bundle
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.cardview.widget.CardView
import com.zubid.app.R
import com.zubid.app.util.LocaleHelper

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

    private var selectedMethod: PaymentMethod = PaymentMethod.STRIPE
    private var productName: String = ""
    private var productPrice: Double = 0.0
    private var auctionId: String = ""

    enum class PaymentMethod { STRIPE, FIB, GOOGLE_PAY, ZAINCASH, COD }

    override fun attachBaseContext(newBase: android.content.Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_payment)

        // Get intent extras
        productName = intent.getStringExtra("product_name") ?: "Product"
        productPrice = intent.getDoubleExtra("product_price", 0.0)
        auctionId = intent.getStringExtra("auction_id") ?: ""

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
        // TODO: Integrate Stripe SDK
        // For now, simulate payment
        btnPay.postDelayed({
            showLoading(false)
            showSuccess()
        }, 2000)
    }

    private fun processFibPayment() {
        showLoading(true)
        // TODO: Integrate FIB payment
        btnPay.postDelayed({
            showLoading(false)
            showSuccess()
        }, 2000)
    }

    private fun processGooglePayPayment() {
        showLoading(true)
        // TODO: Integrate Google Pay SDK
        // For now, simulate payment
        btnPay.postDelayed({
            showLoading(false)
            showSuccess()
        }, 2000)
    }

    private fun processZainCashPayment() {
        showLoading(true)
        // TODO: Integrate ZainCash API
        // For now, simulate payment
        btnPay.postDelayed({
            showLoading(false)
            showSuccess()
        }, 2000)
    }

    private fun processCodPayment() {
        if (!validateDeliveryInfo()) return
        showLoading(true)
        // TODO: Submit COD order
        btnPay.postDelayed({
            showLoading(false)
            showSuccess()
        }, 1500)
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

