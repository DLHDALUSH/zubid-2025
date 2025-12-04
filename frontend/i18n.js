// Internationalization (i18n) Module
// Supports English, Kurdish, and Arabic languages

const translations = {
    en: {
        // Navigation
        nav: {
            home: 'Home',
            auctions: 'Auctions',
            myBids: 'My Bids',
            payments: 'Payments',
            profile: 'Profile',
            admin: 'Admin',
            login: 'Login',
            signUp: 'Sign Up',
            logout: 'Logout'
        },
        // Common
        common: {
            search: 'Search',
            searchPlaceholder: 'Search for auctions, items, categories...',
            loading: 'Loading...',
            error: 'Error',
            success: 'Success',
            cancel: 'Cancel',
            confirm: 'Confirm',
            save: 'Save',
            delete: 'Delete',
            edit: 'Edit',
            create: 'Create',
            update: 'Update',
            close: 'Close',
            back: 'Back',
            next: 'Next',
            previous: 'Previous',
            submit: 'Submit',
            yes: 'Yes',
            no: 'No'
        },
        // Homepage
        home: {
            title: 'ZUBID - Modern Auction Platform',
            browseCategories: 'Browse Categories',
            featuredAuctions: 'Featured Auctions',
            myAuctions: 'My Auctions',
            myBids: 'My Bids',
            viewProfile: 'View Profile',
            viewAll: 'View All'
        },
        // Authentication
        auth: {
            login: 'Login',
            signUp: 'Sign Up',
            logout: 'Logout',
            username: 'Username',
            password: 'Password',
            email: 'Email',
            confirmPassword: 'Confirm Password',
            forgotPassword: 'Forgot Password?',
            loginSuccess: 'Login successful!',
            logoutSuccess: 'Logout successful!',
            registerSuccess: 'Registration successful!',
            loginFailed: 'Login failed. Please check your credentials.',
            registerFailed: 'Registration failed.',
            usernameRequired: 'Username is required',
            passwordRequired: 'Password is required',
            emailRequired: 'Email is required',
            loggingIn: 'Logging in...',
            registering: 'Registering...'
        },
        // Registration
        register: {
            title: 'Create Account',
            createAccount: 'Create Your Account',
            subtitle: 'Join ZUBID to start bidding on amazing auctions',
            username: 'Username',
            email: 'Email',
            password: 'Password',
            confirmPassword: 'Confirm Password',
            idNumber: 'ID Number',
            idNumberPassport: 'ID Number / Passport',
            birthDate: 'Date of Birth',
            address: 'Address',
            phone: 'Phone Number',
            biometricVerification: 'Biometric Verification',
            idCardFront: 'ID Card Front',
            idCardBack: 'ID Card Back',
            idCard: 'ID Card',
            selfie: 'Selfie',
            capture: 'Capture',
            retake: 'Retake',
            clickToChooseDate: 'Click to choose date',
            selectBirthday: 'Select Your Birthday',
            selectDateOfBirth: 'Select your date of birth',
            weakPassword: 'Weak',
            mediumPassword: 'Medium',
            strongPassword: 'Strong',
            accountInfo: 'Account Information',
            identityVerification: 'Identity Verification',
            contactInfo: 'Contact Information',
            usernamePlaceholder: 'Choose a unique username',
            emailPlaceholder: 'your.email@example.com',
            passwordPlaceholder: 'Create a strong password',
            idNumberPlaceholder: 'Enter your national ID or passport number',
            phonePlaceholder: '+1 234 567 8900',
            addressPlaceholder: 'Enter your full address (street, city, state, zip code)',
            usernameHint: 'This will be your display name',
            emailHint: 'We\'ll never share your email',
            passwordHint: 'Use at least 8 characters with numbers and symbols',
            passwordHintShort: 'Use at least 8 characters',
            idNumberHint: 'This will be used for identity verification',
            birthDateHint: 'Your date of birth as shown on your ID card',
            biometricHint: 'Click the button to scan both sides of your ID card and take a selfie',
            biometricHintShort: 'Click the button to scan your ID card and take a selfie',
            scanIdSelfie: 'Scan ID & Take Selfie',
	            idCardCaptured: '✅ ID Card Captured',
            idCardFrontCaptured: '✅ ID Card Front',
            idCardBackCaptured: '✅ ID Card Back',
            selfieCaptured: '✅ Selfie',
            scanIdCard: 'Scan ID Card',
            startCamera: 'Start Camera',
            capturePhoto: 'Capture Photo',
            switchCamera: 'Switch Camera',
            cameraPlaceholder: 'Camera will appear here',
            step1: 'Step 1',
            step2: 'Step 2',
            step3: 'Step 3',
            stepIdFront: 'ID Front',
            stepIdBack: 'ID Back',
            stepSelfie: 'Selfie',
            pending: 'Pending',
            done: 'Done - All Photos Captured',
            doneShort: 'Done - Both Photos Captured',
            alreadyHaveAccount: 'Already have an account?',
            signIn: 'Sign in',
            required: 'Required'
        },
        // Auctions
        auctions: {
            title: 'All Auctions',
            featured: 'Featured Auctions',
            noAuctions: 'No auctions found',
            noAuctionsMessage: 'No auctions found. Try adjusting your filters.',
            currentBid: 'Current Bid',
            startingBid: 'Starting Bid',
            timeLeft: 'Time Left',
            timeRemaining: 'Time Remaining',
            bids: 'Bids',
            bidder: 'Bidder',
            bidHistory: 'Bid History',
            placeBid: 'Place Bid',
            placeABid: 'Place a Bid',
            bidAmount: 'Bid Amount',
            yourBidAmount: 'Your Bid Amount',
            autoBid: 'Auto Bid',
            enableAutoBid: 'Enable Auto-Bid (Maximum Limit)',
            maxAutoBid: 'Max Auto Bid',
            bidPlaced: 'Bid placed successfully',
            bidFailed: 'Failed to place bid',
            minBid: 'Minimum bid',
            minBidInfo: 'Minimum bid: $0.00',
            autoBidInfo: 'Auto-bid will automatically bid up to this amount',
            endingSoon: 'Ending Soon',
            ended: 'Ended',
            active: 'Active',
            cancelled: 'Cancelled',
            winner: 'Winner',
            winning: 'Winning',
            outbid: 'Outbid',
            noBids: 'No bids yet',
            filterBy: 'Filter By',
            sortBy: 'Sort By',
            category: 'Category',
            allCategories: 'All Categories',
            price: 'Price',
            priceHighToLow: 'Price (High to Low)',
            minPrice: 'Min Price',
            maxPrice: 'Max Price',
            timeLeftSort: 'Time Left',
            mostBids: 'Most Bids',
            bidCount: 'Bid Count',
            totalBids: 'Total Bids',
            gridView: 'Grid View',
            listView: 'List View',
            applyFilters: 'Apply Filters',
            reset: 'Reset',
            searchAuctions: 'Search auctions...',
            loadingAuctions: 'Loading auctions...',
            loadingDetails: 'Loading auction details...',
            description: 'Description',
            bidIncrement: 'Bid Increment',
            auctionEnded: 'This auction has ended.',
            winnerInfo: 'Winner information',
            seller: 'Seller',
            sellerName: 'Seller Name',
            sellerEmail: 'Seller Email',
            selectCategory: 'Select Category',
            featureHomepage: 'Feature this auction on homepage'
        },
        // Create Auction
        createAuction: {
            title: 'Create Auction',
            createNewAuction: 'Create New Auction',
            itemName: 'Item Name',
            description: 'Description',
            startingBid: 'Starting Bid',
            startingBidLabel: 'Starting Bid ($)',
            bidIncrement: 'Bid Increment',
            bidIncrementLabel: 'Bid Increment ($)',
            endTime: 'End Time',
            endDateAndTime: 'End Date & Time',
            category: 'Category',
            selectCategory: 'Select Category',
            images: 'Images',
            imageUrls: 'Image URLs (one per line)',
            imageUrlsPlaceholder: 'Enter image URLs, one per line\nhttps://example.com/image1.jpg\nhttps://example.com/image2.jpg',
            imageUrlsHint: 'You can add image URLs. For now, you can use placeholder images or your own hosted images.',
            addImage: 'Add Image',
            featured: 'Featured Auction',
            featureHomepage: 'Feature this auction on homepage',
            create: 'Create Auction',
            creating: 'Creating...',
            success: 'Auction created successfully!',
            failed: 'Failed to create auction'
        },
        // Profile
        profile: {
            title: 'Profile',
            myProfile: 'My Profile',
            accountInfo: 'Account Information',
            username: 'Username',
            email: 'Email',
            idNumber: 'ID Number',
            birthDate: 'Date of Birth',
            address: 'Address',
            phone: 'Phone Number',
            role: 'Role',
            editProfile: 'Edit Profile',
            updateProfile: 'Update Profile',
            saveChanges: 'Save Changes',
            updating: 'Updating...',
            updateSuccess: 'Profile updated successfully!',
            updateFailed: 'Failed to update profile',
            myAuctions: 'My Auctions',
            myBids: 'My Bids',
            totalAuctions: 'Total Auctions',
            totalBids: 'Total Bids',
            loadingProfile: 'Loading profile...',
            usernameCannotChange: 'Username cannot be changed',
            phoneHint: 'We\'ll use this to contact you about your auctions',
            addressHint: 'Required for auction transactions and shipping'
        },
        // Payments
        payments: {
            title: 'Payments',
            invoice: 'Invoice',
            itemPrice: 'Item Price',
            bidFee: 'Bid Fee',
            deliveryFee: 'Delivery Fee',
            totalAmount: 'Total Amount',
            paymentMethod: 'Payment Method',
            paymentStatus: 'Payment Status',
            pending: 'Pending',
            paid: 'Paid',
            failed: 'Failed',
            cancelled: 'Cancelled',
            cashOnDelivery: 'Cash on Delivery',
            fibPayment: 'FIB Payment',
            payNow: 'Pay Now',
            selectPaymentMethod: 'Select Payment Method',
            paymentSuccess: 'Payment processed successfully!',
            paymentFailed: 'Payment failed'
	        },
	        // How to Bid page
	        howToBidPage: {
	            intro: 'Learn how to participate in auctions and place winning bids on ZUBID. Follow these simple steps to get started.',
	            step1Title: 'Create Your Account',
	            step1Text: 'Start by creating a free account on ZUBID. Click the "Sign Up" button in the navigation bar and fill in your details. You\'ll need to provide:',
	            step1Item1: 'Username and email address',
	            step1Item2: 'Secure password',
	            step1Item3: 'Personal information for verification',
	            step1Cta: 'Sign Up Now',
	            step2Title: 'Browse Auctions',
	            step2Text: 'Explore our wide selection of auctions. You can:',
	            step2Item1: 'Browse by category (Electronics, Jewelry, Vehicles, etc.)',
	            step2Item2: 'Search for specific items',
	            step2Item3: 'Filter by price range, status, and more',
	            step2Item4: 'View featured auctions on the homepage',
	            step2Cta: 'Browse Auctions',
	            step3Title: 'View Auction Details',
	            step3Text: 'Click on any auction to see detailed information:',
	            step3Item1: 'High-quality images and descriptions',
	            step3Item2: 'Current bid and bid increment',
	            step3Item3: 'Time remaining (live countdown)',
	            step3Item4: 'Bid history and bidder information',
	            step3Item5: 'Seller information',
	            step4Title: 'Place Your Bid',
	            step4Text: 'When you\'re ready to bid:',
	            step4Item1: 'Enter your bid amount (must be at least the minimum bid)',
	            step4Item2: 'Optionally enable auto-bid with a maximum limit',
	            step4Item3: 'Click "Place Bid" to submit',
	            step4Item4: 'Watch real-time updates as others bid',
	            step4Tip: 'Tip: Use auto-bid to automatically increase your bid up to your maximum limit when others outbid you.',
	            step5Title: 'Win and Pay',
	            step5Text: 'If you win the auction:',
	            step5Item1: 'You\'ll receive a notification when the auction ends',
	            step5Item2: 'An invoice will be generated automatically',
	            step5Item3: 'Complete payment through your preferred method',
	            step5Item4: 'Arrange for delivery or pickup',
	            tipsTitle: 'Bidding Tips',
	            tipsItem1: 'Set a maximum budget before bidding',
	            tipsItem2: 'Use auto-bid to stay competitive automatically',
	            tipsItem3: 'Read item descriptions carefully',
	            tipsItem4: 'Check seller ratings and reviews',
	            tipsItem5: 'Watch the countdown timer closely',
	            tipsItem6: 'Bid early to avoid last-minute rush',
	            faqTitle: 'Frequently Asked Questions',
	            faqQ1: 'Can I retract a bid?',
	            faqA1: 'Bids are final and cannot be retracted. Please bid carefully and only place bids you\'re committed to.',
	            faqQ2: 'What happens if I\'m outbid?',
	            faqA2: 'You\'ll receive a notification. If you have auto-bid enabled, it will automatically place a higher bid up to your maximum limit.',
	            faqQ3: 'How does auto-bid work?',
	            faqA3: 'Auto-bid automatically increases your bid when others outbid you, up to your specified maximum amount.',
	            faqQ4: 'What are the fees?',
	            faqA4: 'There\'s a 1% bid fee on winning bids, plus delivery fees based on your location.',
	            ctaTitle: 'Ready to Start Bidding?',
	            ctaText: 'Join thousands of bidders and discover amazing deals!',
	            ctaPrimary: 'Sign Up Now',
	            ctaSecondary: 'Browse Auctions'
	        },
		// Contact Us page
		contactPage: {
		    intro: 'Get in touch with us. We\'re here to help you with any questions or concerns.',
		    getInTouchTitle: 'Get in Touch',
		    emailTitle: 'Email',
		    phoneTitle: 'Phone',
		    phoneHoursShort: 'Mon-Fri: 9:00 AM - 6:00 PM',
		    addressTitle: 'Address',
		    addressLine1: '123 Auction Street',
		    addressLine2: 'Bidding City, BC 12345',
		    addressLine3: 'Country',
		    businessHoursTitle: 'Business Hours',
		    hoursWeekdays: 'Monday - Friday: 9:00 AM - 6:00 PM',
		    hoursSaturday: 'Saturday: 10:00 AM - 4:00 PM',
		    hoursSunday: 'Sunday: Closed',
		    formTitle: 'Send us a Message',
		    nameLabel: 'Name *',
		    emailLabel: 'Email *',
		    subjectLabel: 'Subject *',
		    subjectPlaceholder: 'Select a subject',
		    subjectGeneral: 'General Inquiry',
		    subjectSupport: 'Technical Support',
		    subjectBidding: 'Bidding Questions',
		    subjectPayment: 'Payment Issues',
		    subjectAccount: 'Account Issues',
		    subjectOther: 'Other',
		    messageLabel: 'Message *',
		    submitButton: 'Send Message'
		},
		// My Bids page
			myBidsPage: {
			    title: 'My Winning Bids',
			    subtitle: 'Showing only auctions you\'ve won or are currently winning',
			    loading: 'Loading your bids...',
			    noWinningTitle: 'You don\'t have any winning bids yet.',
			    noWinningSubtitle: 'Keep bidding to win amazing auctions!',
			    noBidsTitle: 'You haven\'t placed any bids yet.',
			    browseAuctions: 'Browse Auctions',
			    loadError: 'Failed to load your bids. Please try again.',
			    loadErrorShort: 'Failed to load your bids',
			    loginRequired: 'Please login to view your bids',
			    unknownAuction: 'Unknown Auction',
			    unknownTime: 'Unknown time',
			    currentLabel: 'Current:',
				    auctionEndedBadge: 'Auction Ended',
				    statusWon: 'WON',
				    statusWinning: 'WINNING',
				    statusOutbid: 'OUTBID',
				    autoBidBadge: 'Auto-Bid'
			},
	// Admin
        admin: {
            title: 'Admin Dashboard',
            users: 'Users',
            auctions: 'Auctions',
            categories: 'Categories',
            stats: 'Statistics',
            totalUsers: 'Total Users',
            totalAdmins: 'Total Admins',
            totalAuctions: 'Total Auctions',
            activeAuctions: 'Active Auctions',
            endedAuctions: 'Ended Auctions',
            totalBids: 'Total Bids',
            recentUsers: 'Recent Users'
        },
        // Messages
        messages: {
            serverError: 'Cannot connect to server! Make sure the backend is running on port 5000.',
            unauthorized: 'You are not authorized to perform this action',
            notFound: 'Resource not found',
            validationError: 'Please check your input and try again',
            networkError: 'Network error. Please check your connection.',
            genericError: 'An error occurred. Please try again later.',
            invalidAuctionId: 'Invalid auction ID',
            loginRequired: 'Please login to place a bid',
            auctionInactive: 'This auction is no longer active',
            invalidVideoUrl: 'Invalid video URL format',
            noFeaturedAuctions: 'No featured auctions available',
            linkCopied: 'Link copied to clipboard! Paste it in the app.',
            copyLinkManually: 'Please copy the link manually',
            shareSuccess: 'Shared successfully!',
            shareFailed: 'Failed to record share',
            errorRecordingShare: 'Error recording share. Please try again.',
            processing: 'Processing...',
            photoUploaded: 'Photo uploaded successfully',
            passwordRequirementLength: 'At least 8 characters',
            passwordRequirementLowercase: 'One lowercase letter',
            passwordRequirementUppercase: 'One uppercase letter',
            passwordRequirementNumber: 'One number',
            passwordRequirementSpecial: 'One special character (!@#$%^&*()_+-=[]{}|;:,.<>?)',
            passwordMustMeetRequirements: 'Password must meet all requirements above',
	        	    admin: 'Admin',
	        	    howToBid: 'How to Bid',
	        	    contactUs: 'Contact Us',
	        	    returnRequests: 'Return Requests',
	        	    info: 'Info',
	        	    profilePhoto: 'Profile Photo',
	        	    uploadPhoto: 'Upload Photo',
	        	    optional: 'Optional',
	        	    max5MB: 'Max 5MB, JPG/PNG'
        }
    },
    ku: {
        // Navigation
        nav: {
            home: 'سەرەکی',
            auctions: 'بازاڕ',
            myBids: 'داوای من',
            payments: 'پارەدان',
            profile: 'پڕۆفایل',
            admin: 'بەڕێوەبردن',
            login: 'چوونەژوورەوە',
            signUp: 'خۆتۆمارکردن',
            logout: 'دەرچوون'
        },
        // Common
        common: {
            search: 'گەڕان',
            searchPlaceholder: 'بگەڕە بەدوای بازاڕ، کاڵا، جۆرەکان...',
            loading: 'بارکردن...',
            error: 'هەڵە',
            success: 'سەرکەوتوو',
            cancel: 'هەڵوەشاندنەوە',
            confirm: 'دڵنیاکردنەوە',
            save: 'پاشەکەوتکردن',
            delete: 'سڕینەوە',
            edit: 'دەستکاریکردن',
            create: 'دروستکردن',
            update: 'نوێکردنەوە',
            close: 'داخستن',
            back: 'گەڕانەوە',
            next: 'دواتر',
            previous: 'پێشوو',
            submit: 'ناردن',
            yes: 'بەڵێ',
            no: 'نەخێر'
        },
        // Homepage
        home: {
            title: 'ZUBID - پلاتفۆرمی بازاڕی نوێ',
            browseCategories: 'سەیرکردنی جۆرەکان',
            featuredAuctions: 'بازاڕی تایبەت',
            myAuctions: 'بازاڕەکانم',
            myBids: 'داوای من',
            viewProfile: 'بینینی پڕۆفایل',
            viewAll: 'بینینی هەموو'
        },
        // Authentication
        auth: {
            login: 'چوونەژوورەوە',
            signUp: 'خۆتۆمارکردن',
            logout: 'دەرچوون',
            username: 'ناوی بەکارهێنەر',
            password: 'وشەی تێپەڕ',
            email: 'ئیمەیڵ',
            confirmPassword: 'دڵنیاکردنەوەی وشەی تێپەڕ',
            forgotPassword: 'وشەی تێپەڕت لەبیرکردووە?',
            loginSuccess: 'بە سەرکەوتوویی چوویتەژوورەوە!',
            logoutSuccess: 'بە سەرکەوتوویی دەرچوویت!',
            registerSuccess: 'خۆتۆمارکردن بە سەرکەوتوویی بوو!',
            loginFailed: 'چوونەژوورەوە سەرکەوتوو نەبوو. تکایە پشکنین بکە.',
            registerFailed: 'خۆتۆمارکردن سەرکەوتوو نەبوو.',
            usernameRequired: 'ناوی بەکارهێنەر پێویستە',
            passwordRequired: 'وشەی تێپەڕ پێویستە',
            emailRequired: 'ئیمەیڵ پێویستە',
            loggingIn: 'چوونەژوورەوە...',
            registering: 'خۆتۆمارکردن...'
        },
        // Registration
        register: {
            title: 'دروستکردنی هەژمار',
            createAccount: 'دروستکردنی هەژمارت',
            subtitle: 'بەشداری لە ZUBID بکە بۆ دەستپێکردنی داوکردن لە بازاڕە سەرنجڕاکێشەکان',
            username: 'ناوی بەکارهێنەر',
            email: 'ئیمەیڵ',
            password: 'وشەی تێپەڕ',
            confirmPassword: 'دڵنیاکردنەوەی وشەی تێپەڕ',
            idNumber: 'ژمارەی ناسنامە',
            idNumberPassport: 'ژمارەی ناسنامە / پاسپۆرت',
            birthDate: 'بەرواری لەدایکبوون',
            address: 'ناونیشان',
            phone: 'ژمارەی تەلەفۆن',
            biometricVerification: 'پشتڕاستکردنەوەی بایۆمێتریک',
            idCardFront: 'لای پێشووی کارتی ناسنامە',
            idCardBack: 'لای دواوەی کارتی ناسنامە',
            idCard: 'کارتی ناسنامە',
            selfie: 'سێلفی',
            capture: 'گرتن',
            retake: 'دووبارە گرتن',
            clickToChooseDate: 'کرتە بکە بۆ هەڵبژاردنی بەروار',
            selectBirthday: 'بەرواری لەدایکبوونت هەڵبژێرە',
            selectDateOfBirth: 'بەرواری لەدایکبوونت هەڵبژێرە',
            weakPassword: 'لاوەک',
            mediumPassword: 'ناوەند',
            strongPassword: 'بەهێز',
            accountInfo: 'زانیاری هەژمار',
            identityVerification: 'پشتڕاستکردنەوەی ناسنامە',
            contactInfo: 'زانیاری پەیوەندی',
            usernamePlaceholder: 'ناوی بەکارهێنەرێکی تایبەت هەڵبژێرە',
            emailPlaceholder: 'ئیمەیڵ@نموونە.com',
            passwordPlaceholder: 'وشەی تێپەڕێکی بەهێز دروست بکە',
            idNumberPlaceholder: 'ژمارەی ناسنامەی نیشتیمانی یان پاسپۆرت بنووسە',
            phonePlaceholder: '+964 750 123 4567',
            addressPlaceholder: 'ناونیشانی تەواوت بنووسە (شەقام، شار، پارێزگا، کۆدی پۆست)',
            usernameHint: 'ئەمە ناوی پیشاندانەکەت دەبێت',
            emailHint: 'ئیمەیڵەکەت هەرگیز ناشارێتەوە',
            passwordHint: 'کەمتر لە 8 پیت بەکارهێنە لەگەڵ ژمارە و هێما',
            passwordHintShort: 'کەمتر لە 8 پیت بەکارهێنە',
            idNumberHint: 'ئەمە بۆ پشتڕاستکردنەوەی ناسنامە بەکاردێت',
            birthDateHint: 'بەرواری لەدایکبوونەکەت وەک لە کارتی ناسنامەکەتدا دیارە',
            biometricHint: 'دوگمەکە بگرە بۆ سکانکردنی هەردوو لای کارتی ناسنامەکەت و وەرگرتنی سێلفی',
            biometricHintShort: 'دوگمەکە بگرە بۆ سکانکردنی کارتی ناسنامەکەت و وەرگرتنی سێلفی',
            scanIdSelfie: 'کارتی ناسنامە سکان بکە و سێلفی بگرە',
            idCardCaptured: '✅ کارتی ناسنامە گیرایەوە',
            idCardFrontCaptured: '✅ لای پێشووی کارتی ناسنامە',
            idCardBackCaptured: '✅ لای دواوەی کارتی ناسنامە',
            selfieCaptured: '✅ سێلفی',
            scanIdCard: 'سکانکردنی کارتی ناسنامە',
            startCamera: 'دەستپێکردنی کامێرا',
            capturePhoto: 'گرتنی وێنە',
            switchCamera: 'گۆڕینی کامێرا',
            cameraPlaceholder: 'کامێرا لێرە دەردەکەوێت',
            step1: 'هەنگاو ١',
            step2: 'هەنگاو ٢',
            step3: 'هەنگاو ٣',
            stepIdFront: 'لای پێشوو',
            stepIdBack: 'لای دواوە',
            stepSelfie: 'سێلفی',
            pending: 'چاوەڕوان',
            done: 'تەواو - هەموو وێنەکان گیراون',
            doneShort: 'تەواو - هەردوو وێنە گیراون',
            alreadyHaveAccount: 'هەژمارت هەیە؟',
            signIn: 'چوونەژوورەوە',
            required: 'پێویستە'
        },
        // Auctions
        auctions: {
            title: 'هەموو بازاڕەکان',
            featured: 'بازاڕی تایبەت',
            noAuctions: 'هیچ بازاڕێک نەدۆزرایەوە',
            noAuctionsMessage: 'هیچ بازاڕێک نەدۆزرایەوە. هەوڵ بدە فلتەرەکانت بگۆڕیت.',
            currentBid: 'داوی ئێستا',
            startingBid: 'داوی دەستپێکردن',
            timeLeft: 'کاتی ماوە',
            timeRemaining: 'کاتی ماوە',
            bids: 'داو',
            bidder: 'داوکار',
            bidHistory: 'مێژووی داو',
            placeBid: 'داوکردن',
            placeABid: 'داوکردن',
            bidAmount: 'بڕی داو',
            yourBidAmount: 'بڕی داوەکەت',
            autoBid: 'داوکردنی خۆکار',
            enableAutoBid: 'داوکردنی خۆکار چالاک بکە (سنووری کەمترین)',
            maxAutoBid: 'کەمترین داو',
            bidPlaced: 'داو بە سەرکەوتوویی نێردرا',
            bidFailed: 'داوکردن سەرکەوتوو نەبوو',
            minBid: 'کەمترین داو',
            minBidInfo: 'کەمترین داو: $0.00',
            autoBidInfo: 'داوکردنی خۆکار خۆکارانە داو دەکات تا ئەم بڕە',
            endingSoon: 'بە زوویی کۆتایی دێت',
            ended: 'کۆتایی هات',
            active: 'چالاک',
            cancelled: 'هەڵوەشێنراوە',
            winner: 'براوە',
            winning: 'بردن',
            outbid: 'زیاتر داوکرا',
            noBids: 'هیچ داوێک نییە',
            filterBy: 'فلتەرکردن بەپێی',
            sortBy: 'ڕیزکردن بەپێی',
            category: 'جۆر',
            allCategories: 'هەموو جۆرەکان',
            price: 'نرخ',
            priceHighToLow: 'نرخ (بەرز بۆ نزم)',
            minPrice: 'کەمترین نرخ',
            maxPrice: 'زۆرترین نرخ',
            timeLeftSort: 'کاتی ماوە',
            mostBids: 'زۆرترین داو',
            bidCount: 'ژمارەی داو',
            totalBids: 'کۆی داو',
            gridView: 'بینینی گرید',
            listView: 'بینینی لیست',
            applyFilters: 'جێبەجێکردنی فلتەر',
            reset: 'دووبارە دامەزراندنەوە',
            searchAuctions: 'گەڕان لە بازاڕ...',
            loadingAuctions: 'بارکردنی بازاڕ...',
            loadingDetails: 'بارکردنی وردەکاریەکانی بازاڕ...',
            description: 'وەسف',
            bidIncrement: 'زیادکردنی داو',
            auctionEnded: 'ئەم بازاڕە کۆتایی هاتووە.',
            winnerInfo: 'زانیاری براوە',
            seller: 'فرۆشەر',
            sellerName: 'ناوی فرۆشەر',
            sellerEmail: 'ئیمەیڵی فرۆشەر',
            selectCategory: 'جۆر هەڵبژێرە',
            featureHomepage: 'ئەم بازاڕە لە پەڕەی سەرەکی پیشان بدە'
        },
        // Create Auction
        createAuction: {
            title: 'دروستکردنی بازاڕ',
            createNewAuction: 'دروستکردنی بازاڕی نوێ',
            itemName: 'ناوی کاڵا',
            description: 'وەسف',
            startingBid: 'داوی دەستپێکردن',
            startingBidLabel: 'داوی دەستپێکردن ($)',
            bidIncrement: 'زیادکردنی داو',
            bidIncrementLabel: 'زیادکردنی داو ($)',
            endTime: 'کاتی کۆتایی',
            endDateAndTime: 'بەروار و کاتی کۆتایی',
            category: 'جۆر',
            selectCategory: 'جۆر هەڵبژێرە',
            images: 'وێنە',
            imageUrls: 'لینکی وێنە (هەر یەک لە دێڕێکی جیاواز)',
            imageUrlsPlaceholder: 'لینکی وێنە بنووسە، هەر یەک لە دێڕێکی جیاواز\nhttps://example.com/image1.jpg\nhttps://example.com/image2.jpg',
            imageUrlsHint: 'دەتوانیت لینکی وێنە زیاد بکەیت. بۆ ئێستا دەتوانیت وێنەی پلەیس هۆڵدەر بەکاربهێنیت یان وێنەی میزبانکراوەکانی خۆت.',
            addImage: 'زیادکردنی وێنە',
            featured: 'بازاڕی تایبەت',
            featureHomepage: 'ئەم بازاڕە لە پەڕەی سەرەکی پیشان بدە',
            create: 'دروستکردنی بازاڕ',
            creating: 'دروستکردن...',
            success: 'بازاڕ بە سەرکەوتوویی دروستکرا!',
            failed: 'دروستکردنی بازاڕ سەرکەوتوو نەبوو'
        },
        // Profile
        profile: {
            title: 'پڕۆفایل',
            myProfile: 'پڕۆفایلی من',
            accountInfo: 'زانیاری هەژمار',
            username: 'ناوی بەکارهێنەر',
            email: 'ئیمەیڵ',
            idNumber: 'ژمارەی ناسنامە',
            birthDate: 'بەرواری لەدایکبوون',
            address: 'ناونیشان',
            phone: 'ژمارەی تەلەفۆن',
            role: 'رۆڵ',
            editProfile: 'دەستکاریکردنی پڕۆفایل',
            updateProfile: 'نوێکردنەوەی پڕۆفایل',
            saveChanges: 'پاشەکەوتکردنی گۆڕانکاریەکان',
            updating: 'نوێکردنەوە...',
            updateSuccess: 'پڕۆفایل بە سەرکەوتوویی نوێکرایەوە!',
            updateFailed: 'نوێکردنەوەی پڕۆفایل سەرکەوتوو نەبوو',
            myAuctions: 'بازاڕەکانم',
            myBids: 'داوای من',
            totalAuctions: 'کۆی بازاڕەکان',
            totalBids: 'کۆی داو',
            loadingProfile: 'بارکردنی پڕۆفایل...',
            usernameCannotChange: 'ناوی بەکارهێنەر ناتوانرێت بگۆڕدرێت',
            phoneHint: 'ئەمە بەکاردێت بۆ پەیوەندیکردن لەگەڵت دەربارەی بازاڕەکانت',
            addressHint: 'پێویستە بۆ کاروباری بازاڕ و شاردنەوە'
        },
        // Payments
        payments: {
            title: 'پارەدان',
            invoice: 'صورتحساب',
            itemPrice: 'نرخی کاڵا',
            bidFee: 'کرێی داو',
            deliveryFee: 'کرێی گەیاندن',
            totalAmount: 'کۆی گشتی',
            paymentMethod: 'شێوازی پارەدان',
            paymentStatus: 'دۆخی پارەدان',
            pending: 'چاوەڕوان',
            paid: 'پارە دراوە',
            failed: 'سەرکەوتوو نەبوو',
            cancelled: 'هەڵوەشێنراوە',
            cashOnDelivery: 'پارە لەکاتی گەیاندندا',
            fibPayment: 'پارەدانی FIB',
            payNow: 'ئێستا پارە بدە',
            selectPaymentMethod: 'شێوازی پارەدان هەڵبژێرە',
	            paymentSuccess: 'پارەدان بە سەرکەوتوویی جێبەجێکرا!',
	            paymentFailed: 'پارەدان سەرکەوتوو نەبوو'
	        },
	        // How to Bid page
	        howToBidPage: {
	            intro: 'فێربە چۆن بەژداربیت لە بازاڕەکان و داوەکانی سەرکەوتووی لە ZUBID بکەیت. ئەم هەنگاوە ئاسانانە بەدواداەوە بکە بۆ دەستپێکردن.',
	            step1Title: 'هەژمارەکەت دروست بکە',
	            step1Text: 'لەگەڵ دروستکردنی هەژماری خۆڕایی لە ZUBID دەست بکە. دوگمەی "خۆتۆمارکردن" لە سەر شریتی سەرەوە بکە و زانیاریەکانت پڕبکەرەوە. دەبێت ئەمانە دابین بکەیت:',
	            step1Item1: 'ناوی بەکارهێنەر و ئیمەیڵ',
	            step1Item2: 'وشەی تێپەڕێکی بەهێز',
	            step1Item3: 'زانیاری کەسی بۆ پشتڕاستکردنەوە',
	            step1Cta: 'ئێستا خۆتۆمار بکە',
	            step2Title: 'سەیرکردنی بازاڕەکان',
	            step2Text: 'کۆمەڵە بازاڕی جۆراوجۆر بسەیرە. دەتوانیت:',
	            step2Item1: 'بگەڕێیت بەدوای جۆرەکان (ئەلێکترۆنیات، زێوەر، ئۆتۆمبێل و هتد.)',
	            step2Item2: 'بگەڕێیت بە دوای کاڵای دیاریکراو',
	            step2Item3: 'فلتەر بکە بە نرخ، دۆخ و هتد.',
	            step2Item4: 'بازاڕە تایبەتەکان لە پەڕەی سەرەکی ببینە',
	            step2Cta: 'سەیرکردنی بازاڕەکان',
	            step3Title: 'بینینی وردەکاری بازاڕ',
	            step3Text: 'کرتە لەسەر هەر بازاڕێک بکە بۆ بینینی زانیاری ورد:',
	            step3Item1: 'وێنە و وەسفی بەرزجۆر',
	            step3Item2: 'داوی ئێستا و زیادکردنی داو',
	            step3Item3: 'کاتی ماوە (ژمێرەری ڕاستەوخۆ)',
	            step3Item4: 'مێژووی داو و زانیاری داوکاران',
	            step3Item5: 'زانیاری فرۆشەر',
	            step4Title: 'داوەکەت بنووسە',
	            step4Text: 'کاتێک ئامادەیت بۆ داوکردن:',
	            step4Item1: 'بڕی داوەکەت بنووسە (دەبێت کەمتر نەبێت لە کەمترین داو)',
	            step4Item2: 'ئەتوانی داوکردنی خۆکار چالاک بکەیت بە سنووری زۆرترین',
	            step4Item3: 'دوگمەی "داوکردن" بکە بۆ ناردن',
	            step4Item4: 'نوێکاریەکانی داوەکان بە کاتێکی ڕاستەوخۆ ببینە',
	            step4Tip: 'ئاگادارکردنەوە: داوکردنی خۆکار بەکاربهێنە بۆ زیادکردنی داوەکانت خۆکارانە تا سنووری دیاریکراوەکەت ئەگەر کەسێکی تر داوی زیاتر بکات.',
	            step5Title: 'بردن و پارەدان',
	            step5Text: 'ئەگەر براوە بیت لە بازاڕ:',
	            step5Item1: 'کاتێک بازاڕەکە کۆتایی دێت ئاگادار دەکرێیتەوە',
	            step5Item2: 'فاکتور خۆکارانە دروست دەکرێت',
	            step5Item3: 'پارەدان بکە بە ڕێگای حەزکراوت',
	            step5Item4: 'ڕێکبخە بۆ ناردن یان وەرگرتن',
	            tipsTitle: 'ڕاوێژەکانی داوکردن',
	            tipsItem1: 'پێش داوکردن بڕی بودجەی زۆرترین دیاربکە',
	            tipsItem2: 'داوکردنی خۆکار بەکاربهێنە بۆ ماندوونەبوون لە ڕکابەری',
	            tipsItem3: 'وردەکاریەکانی وەسفی کاڵا بە وریایی بخوێنەوە',
	            tipsItem4: 'هەڵسەنگاندن و کۆمێنتەکانی فرۆشەر بپشکنە',
	            tipsItem5: 'کاتژمێرەکە بە وریایی چاودێری بکە',
	            tipsItem6: 'زوو داو بکە بۆ دووربوون لە قەرەباڵغی کاتی کۆتا',
	            faqTitle: 'پرسیارە دووبارە پرسیارەکان',
	            faqQ1: 'دەتوانم داوم ڕەشبکەمەوە؟',
	            faqA1: 'داوەکان کۆتاییین و ناتوانرێت ڕەشبکرێنەوە. تکایە بە وریایی داو بکە و تەنها داوێک بدە کە دڵنیایت لێی.',
	            faqQ2: 'ئەگەر کەسێکی تر داوی زیاتر بکات چی دەبێت؟',
	            faqA2: 'ئاگادار دەکرێیتەوە. ئەگەر داوکردنی خۆکار چالاکت کردووە، خۆکارانە داوی بەرزتر دەنووسێت تا سنووری دیاریکراوەکەت.',
	            faqQ3: 'داوکردنی خۆکار چۆن کاردەکات؟',
	            faqA3: 'داوکردنی خۆکار خۆکارانە داوەکەت زیاد دەکات کاتێک کەسێکی تر داوی زیاتر دەنووسێت، تا ئەو بڕەی دیاریکراوە.',
	            faqQ4: 'کرێکان چەنە؟',
	            faqA4: '١٪ کرێی داو لەسەر داوەکانی بردن هەیە، زیادتر لە کرێی ناردن بەپێی شوێنەکەت.',
	            ctaTitle: 'ئامادەیت بۆ دەستپێکردن بە داوکردن؟',
	            ctaText: 'هاوڵاتی هەزاران داوکار بە و ببینە ڕێکەوتە باشەکان!',
	            ctaPrimary: 'ئێستا خۆتۆمار بکە',
	            ctaSecondary: 'سەیرکردنی بازاڕەکان'
	        },
	        // Contact Us page
	        contactPage: {
	            intro: 'پەیوەندی بەمان بکە. ئێمە لێرەین بۆ یارمەتیدانت لە هەر پرسیارو نیگەرانیک.',
	            getInTouchTitle: 'پەیوەندی بکە',
	            emailTitle: 'ئیمەیڵ',
	            phoneTitle: 'تەلەفۆن',
	            phoneHoursShort: 'دوو شەمە - هەینی: 9:00 - 18:00',
	            addressTitle: 'ناونیشان',
	            addressLine1: '123 شەقامی بازاڕ',
	            addressLine2: 'شاری داوکردن، BC 12345',
	            addressLine3: 'وڵات',
	            businessHoursTitle: 'کاتەکانی کارکردن',
	            hoursWeekdays: 'دوو شەمە - هەینی: 9:00 - 18:00',
	            hoursSaturday: 'شەمە: 10:00 - 16:00',
	            hoursSunday: 'یەکشەمە: داخراوە',
	            formTitle: 'پەیامێک بنێرە بۆ ئێمە',
	            nameLabel: 'ناو *',
	            emailLabel: 'ئیمەیڵ *',
	            subjectLabel: 'ناونیشانی پەیام *',
	            subjectPlaceholder: 'بابەتێک هەڵبژێرە',
	            subjectGeneral: 'پرسیاری گشتی',
	            subjectSupport: 'پاڵپشتی تەکنیکی',
	            subjectBidding: 'پرسیاری داوکردن',
	            subjectPayment: 'کێشەکانی پارەدان',
	            subjectAccount: 'کێشەکانی هەژمار',
	            subjectOther: 'هتد.',
	            messageLabel: 'پەیام *',
	            submitButton: 'ناردنی پەیام'
	        },
		        // My Bids page
		        myBidsPage: {
		            title: 'داوە بەردووەکانم',
		            subtitle: 'تەنها ئەو بازاڕانە پیشان دەدرێن کە بردووت یان ئێستا پێش دەچیت',
		            loading: 'داوەکانت دەبارێن...',
		            noWinningTitle: 'هێشتا هیچ داوی بردووت نییە.',
		            noWinningSubtitle: 'بەردەوام بە لە داوکردن بۆ بردنی بازاڕە جوانەکان!',
		            noBidsTitle: 'هێشتا هیچ داوێکت نەنووسیوە.',
		            browseAuctions: 'سەیرکردنی بازاڕەکان',
		            loadError: 'نەتوانرا داوەکانت باربکرێن. تکایە دووبارە هەوڵ بدە.',
		            loadErrorShort: 'نەتوانرا داوەکانت باربکرێن',
		            loginRequired: 'تکایە بچۆرەژوورەوە بۆ بینینی داوەکانت',
		            unknownAuction: 'بازاڕی نەزانراو',
		            unknownTime: 'کاتی نەزانراو',
		            currentLabel: 'داوی ئێستا:',
		            auctionEndedBadge: 'بازاڕ کۆتایی هاتوو',
		            statusWon: 'بردوو',
		            statusWinning: 'پێش دەچیت',
		            statusOutbid: 'داوکە شیتر بەرزترە',
		            autoBidBadge: 'داوی خۆکار'
		        },
	        // Admin
        admin: {
            title: 'داشبۆردی بەڕێوەبردن',
            users: 'بەکارهێنەران',
            auctions: 'بازاڕەکان',
            categories: 'جۆرەکان',
            stats: 'ئامارەکان',
            totalUsers: 'کۆی بەکارهێنەران',
            totalAdmins: 'کۆی بەڕێوەبردن',
            totalAuctions: 'کۆی بازاڕەکان',
            activeAuctions: 'بازاڕی چالاک',
            endedAuctions: 'بازاڕی کۆتایی پێهاتوو',
            totalBids: 'کۆی داو',
            recentUsers: 'بەکارهێنەری نوێ'
        },
        // Messages
        messages: {
            serverError: 'ناتوانیت بگەیتە سێرڤەر! دڵنیاببەوە کە بەک-ئێند لە پۆرتی 5000 کاردەکات.',
            unauthorized: 'تۆ مۆڵەتت نییە بۆ ئەم کارە',
            notFound: 'سەرچاوەکە نەدۆزرایەوە',
            validationError: 'تکایە داتاکانت پشکنین بکە و دوبارە هەوڵ بدە',
            networkError: 'هەڵەی تۆڕ. تکایە پشکنینی پەیوەندیت بکە.',
            genericError: 'هەڵەیەک ڕوویدا. تکایە دواتر هەوڵ بدەوە.',
            invalidAuctionId: 'ژمارەی بازاڕ نادروستە',
            loginRequired: 'تکایە بچۆرەژوورەوە بۆ داوکردن',
            auctionInactive: 'ئەم بازاڕە چیتر چالاک نییە',
            invalidVideoUrl: 'شێوازی لینکی ڤیدیۆ نادروستە',
            noFeaturedAuctions: 'هیچ بازاڕێکی تایبەت بەردەست نییە',
            linkCopied: 'لینک کۆپی کرا بۆ کلیپبۆرد! لە ئەپدا پیست بکە.',
            copyLinkManually: 'تکایە لینکەکە بە دەستی کۆپی بکە',
            shareSuccess: 'بە سەرکەوتوویی هاوبەش کرا!',
            shareFailed: 'هاوبەشکردن سەرکەوتوو نەبوو',
            errorRecordingShare: 'هەڵە لە تۆمارکردنی هاوبەشکردندا. تکایە دوبارە هەوڵ بدەوە.',
            processing: 'پرۆسێسکردن...',
            photoUploaded: 'وێنە بە سەرکەوتوویی بارکرا',
            passwordRequirementLength: 'کەمتر لە 8 پیت',
            passwordRequirementLowercase: 'یەک پیتی بچووک',
            passwordRequirementUppercase: 'یەک پیتی گەورە',
            passwordRequirementNumber: 'یەک ژمارە',
            passwordRequirementSpecial: 'یەک هێمای تایبەت (!@#$%^&*()_+-=[]{}|;:,.<>?)',
            passwordMustMeetRequirements: 'وشەی تێپەڕ دەبێت هەموو پێویستییەکان بپڕێت',
            admin: 'بەڕێوەبردن',
            howToBid: 'چۆن داو بکەیت',
            contactUs: 'پەیوەندی بەمانا',
	            returnRequests: 'داوای گەڕاندنەوە',
	            info: 'زانیاری',
	            profilePhoto: 'وێنەی پڕۆفایل',
            uploadPhoto: 'بارکردنی وێنە',
            optional: 'دڵخواز',
            max5MB: 'کەمتر لە 5MB، JPG/PNG'
        }
    },
    ar: {
        // Navigation
        nav: {
            home: 'الرئيسية',
            auctions: 'المزادات',
            myBids: 'عروضي',
            payments: 'المدفوعات',
            profile: 'الملف الشخصي',
            admin: 'الإدارة',
            login: 'تسجيل الدخول',
            signUp: 'إنشاء حساب',
            logout: 'تسجيل الخروج'
        },
        // Common
        common: {
            search: 'بحث',
            searchPlaceholder: 'ابحث عن المزادات، العناصر، الفئات...',
            loading: 'جاري التحميل...',
            error: 'خطأ',
            success: 'نجح',
            cancel: 'إلغاء',
            confirm: 'تأكيد',
            save: 'حفظ',
            delete: 'حذف',
            edit: 'تعديل',
            create: 'إنشاء',
            update: 'تحديث',
            close: 'إغلاق',
            back: 'رجوع',
            next: 'التالي',
            previous: 'السابق',
            submit: 'إرسال',
            yes: 'نعم',
            no: 'لا'
        },
        // Homepage
        home: {
            title: 'ZUBID - منصة المزادات الحديثة',
            browseCategories: 'تصفح الفئات',
            featuredAuctions: 'المزادات المميزة',
            myAuctions: 'مزاداتي',
            myBids: 'عروضي',
            viewProfile: 'عرض الملف الشخصي',
            viewAll: 'عرض الكل'
        },
        // Authentication
        auth: {
            login: 'تسجيل الدخول',
            signUp: 'إنشاء حساب',
            logout: 'تسجيل الخروج',
            username: 'اسم المستخدم',
            password: 'كلمة المرور',
            email: 'البريد الإلكتروني',
            confirmPassword: 'تأكيد كلمة المرور',
            forgotPassword: 'نسيت كلمة المرور؟',
            loginSuccess: 'تم تسجيل الدخول بنجاح!',
            logoutSuccess: 'تم تسجيل الخروج بنجاح!',
            registerSuccess: 'تم التسجيل بنجاح!',
            loginFailed: 'فشل تسجيل الدخول. يرجى التحقق من بياناتك.',
            registerFailed: 'فشل التسجيل.',
            usernameRequired: 'اسم المستخدم مطلوب',
            passwordRequired: 'كلمة المرور مطلوبة',
            emailRequired: 'البريد الإلكتروني مطلوب',
            loggingIn: 'جارٍ تسجيل الدخول...',
            registering: 'جارٍ التسجيل...'
        },
        // Registration
        register: {
            title: 'إنشاء حساب',
            createAccount: 'إنشاء حسابك',
            subtitle: 'انضم إلى ZUBID لبدء المزايدة على المزادات الرائعة',
            username: 'اسم المستخدم',
            email: 'البريد الإلكتروني',
            password: 'كلمة المرور',
            confirmPassword: 'تأكيد كلمة المرور',
            idNumber: 'رقم الهوية',
            idNumberPassport: 'رقم الهوية / جواز السفر',
            birthDate: 'تاريخ الميلاد',
            address: 'العنوان',
            phone: 'رقم الهاتف',
            biometricVerification: 'التحقق الحيوي',
            idCardFront: 'وجه بطاقة الهوية',
            idCardBack: 'ظهر بطاقة الهوية',
            idCard: 'بطاقة الهوية',
            selfie: 'صورة شخصية',
            capture: 'التقاط',
            retake: 'إعادة التقاط',
            clickToChooseDate: 'انقر لاختيار التاريخ',
            selectBirthday: 'اختر تاريخ ميلادك',
            selectDateOfBirth: 'اختر تاريخ ميلادك',
            weakPassword: 'ضعيف',
            mediumPassword: 'متوسط',
            strongPassword: 'قوي',
            accountInfo: 'معلومات الحساب',
            identityVerification: 'التحقق من الهوية',
            contactInfo: 'معلومات الاتصال',
            usernamePlaceholder: 'اختر اسم مستخدم فريد',
            emailPlaceholder: 'بريدك@example.com',
            passwordPlaceholder: 'أنشئ كلمة مرور قوية',
            idNumberPlaceholder: 'أدخل رقم الهوية الوطنية أو جواز السفر',
            phonePlaceholder: '+964 750 123 4567',
            addressPlaceholder: 'أدخل عنوانك الكامل (الشارع، المدينة، المحافظة، الرمز البريدي)',
            usernameHint: 'هذا سيكون اسم العرض الخاص بك',
            emailHint: 'لن نشارك بريدك الإلكتروني أبداً',
            passwordHint: 'استخدم 8 أحرف على الأقل مع أرقام ورموز',
            passwordHintShort: 'استخدم 8 أحرف على الأقل',
            idNumberHint: 'سيتم استخدام هذا للتحقق من الهوية',
            birthDateHint: 'تاريخ ميلادك كما هو موضح في بطاقة الهوية',
            biometricHint: 'انقر على الزر لمسح جانبي بطاقة الهوية وأخذ صورة شخصية',
            biometricHintShort: 'انقر على الزر لمسح بطاقة الهوية وأخذ صورة شخصية',
            scanIdSelfie: 'مسح بطاقة الهوية وأخذ صورة شخصية',
            idCardCaptured: '✅ تم التقاط بطاقة الهوية',
            idCardFrontCaptured: '✅ وجه بطاقة الهوية',
            idCardBackCaptured: '✅ ظهر بطاقة الهوية',
            selfieCaptured: '✅ صورة شخصية',
            scanIdCard: 'مسح بطاقة الهوية',
            startCamera: 'بدء الكاميرا',
            capturePhoto: 'التقاط صورة',
            switchCamera: 'تبديل الكاميرا',
            cameraPlaceholder: 'ستظهر الكاميرا هنا',
            step1: 'الخطوة ١',
            step2: 'الخطوة ٢',
            step3: 'الخطوة ٣',
            stepIdFront: 'الوجه',
            stepIdBack: 'الظهر',
            stepSelfie: 'صورة شخصية',
            pending: 'قيد الانتظار',
            done: 'تم - تم التقاط جميع الصور',
            doneShort: 'تم - تم التقاط الصورتين',
            alreadyHaveAccount: 'لديك حساب بالفعل؟',
            signIn: 'تسجيل الدخول',
            required: 'مطلوب'
        },
        // Auctions
        auctions: {
            title: 'جميع المزادات',
            featured: 'المزادات المميزة',
            noAuctions: 'لم يتم العثور على مزادات',
            noAuctionsMessage: 'لم يتم العثور على مزادات. حاول تعديل المرشحات.',
            currentBid: 'العرض الحالي',
            startingBid: 'السعر الابتدائي',
            timeLeft: 'الوقت المتبقي',
            timeRemaining: 'الوقت المتبقي',
            bids: 'عروض',
            bidder: 'المزايد',
            bidHistory: 'سجل العروض',
            placeBid: 'تقديم عرض',
            placeABid: 'تقديم عرض',
            bidAmount: 'مبلغ العرض',
            yourBidAmount: 'مبلغ عرضك',
            autoBid: 'عرض تلقائي',
            enableAutoBid: 'تفعيل العرض التلقائي (الحد الأقصى)',
            maxAutoBid: 'الحد الأقصى للعرض',
            bidPlaced: 'تم تقديم العرض بنجاح',
            bidFailed: 'فشل تقديم العرض',
            minBid: 'الحد الأدنى للعرض',
            minBidInfo: 'الحد الأدنى للعرض: $0.00',
            autoBidInfo: 'سيعرض العرض التلقائي تلقائياً حتى هذا المبلغ',
            endingSoon: 'ينتهي قريباً',
            ended: 'انتهى',
            active: 'نشط',
            cancelled: 'ملغي',
            winner: 'الفائز',
            winning: 'فائز',
            outbid: 'تم تجاوز عرضك',
            noBids: 'لا توجد عروض بعد',
            filterBy: 'تصفية حسب',
            sortBy: 'ترتيب حسب',
            category: 'الفئة',
            allCategories: 'جميع الفئات',
            price: 'السعر',
            priceHighToLow: 'السعر (من الأعلى إلى الأدنى)',
            minPrice: 'الحد الأدنى للسعر',
            maxPrice: 'الحد الأقصى للسعر',
            timeLeftSort: 'الوقت المتبقي',
            mostBids: 'أكثر العروض',
            bidCount: 'عدد العروض',
            totalBids: 'إجمالي العروض',
            gridView: 'عرض الشبكة',
            listView: 'عرض القائمة',
            applyFilters: 'تطبيق المرشحات',
            reset: 'إعادة تعيين',
            searchAuctions: 'بحث في المزادات...',
            loadingAuctions: 'جارٍ تحميل المزادات...',
            loadingDetails: 'جارٍ تحميل تفاصيل المزاد...',
            description: 'الوصف',
            bidIncrement: 'زيادة العرض',
            auctionEnded: 'انتهى هذا المزاد.',
            winnerInfo: 'معلومات الفائز',
            seller: 'البائع',
            sellerName: 'اسم البائع',
            sellerEmail: 'بريد البائع الإلكتروني',
            selectCategory: 'اختر الفئة',
            featureHomepage: 'اعرض هذا المزاد على الصفحة الرئيسية'
        },
        // Create Auction
        createAuction: {
            title: 'إنشاء مزاد',
            createNewAuction: 'إنشاء مزاد جديد',
            itemName: 'اسم العنصر',
            description: 'الوصف',
            startingBid: 'السعر الابتدائي',
            startingBidLabel: 'السعر الابتدائي ($)',
            bidIncrement: 'زيادة العرض',
            bidIncrementLabel: 'زيادة العرض ($)',
            endTime: 'وقت الانتهاء',
            endDateAndTime: 'تاريخ ووقت الانتهاء',
            category: 'الفئة',
            selectCategory: 'اختر الفئة',
            images: 'الصور',
            imageUrls: 'روابط الصور (واحد لكل سطر)',
            imageUrlsPlaceholder: 'أدخل روابط الصور، واحد لكل سطر\nhttps://example.com/image1.jpg\nhttps://example.com/image2.jpg',
            imageUrlsHint: 'يمكنك إضافة روابط الصور. في الوقت الحالي، يمكنك استخدام صور بديلة أو صورك المستضافة.',
            addImage: 'إضافة صورة',
            featured: 'مزاد مميز',
            featureHomepage: 'اعرض هذا المزاد على الصفحة الرئيسية',
            create: 'إنشاء مزاد',
            creating: 'جارٍ الإنشاء...',
            success: 'تم إنشاء المزاد بنجاح!',
            failed: 'فشل إنشاء المزاد'
        },
        // Profile
        profile: {
            title: 'الملف الشخصي',
            myProfile: 'ملفي الشخصي',
            accountInfo: 'معلومات الحساب',
            username: 'اسم المستخدم',
            email: 'البريد الإلكتروني',
            idNumber: 'رقم الهوية',
            birthDate: 'تاريخ الميلاد',
            address: 'العنوان',
            phone: 'رقم الهاتف',
            role: 'الدور',
            editProfile: 'تعديل الملف الشخصي',
            updateProfile: 'تحديث الملف الشخصي',
            saveChanges: 'حفظ التغييرات',
            updating: 'جارٍ التحديث...',
            updateSuccess: 'تم تحديث الملف الشخصي بنجاح!',
            updateFailed: 'فشل تحديث الملف الشخصي',
            myAuctions: 'مزاداتي',
            myBids: 'عروضي',
            totalAuctions: 'إجمالي المزادات',
            totalBids: 'إجمالي العروض',
            loadingProfile: 'جارٍ تحميل الملف الشخصي...',
            usernameCannotChange: 'لا يمكن تغيير اسم المستخدم',
            phoneHint: 'سنستخدم هذا للاتصال بك بشأن مزاداتك',
            addressHint: 'مطلوب لمعاملات المزاد والشحن'
        },
        // Payments
        payments: {
            title: 'المدفوعات',
            invoice: 'الفاتورة',
            itemPrice: 'سعر العنصر',
            bidFee: 'رسوم العرض',
            deliveryFee: 'رسوم التوصيل',
            totalAmount: 'المبلغ الإجمالي',
            paymentMethod: 'طريقة الدفع',
            paymentStatus: 'حالة الدفع',
            pending: 'قيد الانتظار',
            paid: 'مدفوع',
            failed: 'فشل',
            cancelled: 'ملغي',
            cashOnDelivery: 'الدفع عند الاستلام',
            fibPayment: 'دفع FIB',
            payNow: 'ادفع الآن',
            selectPaymentMethod: 'اختر طريقة الدفع',
	            paymentSuccess: 'تم معالجة الدفع بنجاح!',
	            paymentFailed: 'فشل الدفع'
	        },
	        // How to Bid page
	        howToBidPage: {
	            intro: 'تعلم كيف تشارك في المزادات وتقدم عروضاً رابحة على ZUBID. اتبع هذه الخطوات البسيطة للبدء.',
	            step1Title: 'إنشاء حسابك',
	            step1Text: 'ابدأ بإنشاء حساب مجاني على ZUBID. انقر على زر "إنشاء حساب" في شريط التنقل واملأ بياناتك. ستحتاج إلى:',
	            step1Item1: 'اسم المستخدم والبريد الإلكتروني',
	            step1Item2: 'كلمة مرور قوية',
	            step1Item3: 'معلومات شخصية للتحقق من الهوية',
	            step1Cta: 'إنشاء حساب الآن',
	            step2Title: 'تصفح المزادات',
	            step2Text: 'استكشف مجموعتنا الواسعة من المزادات. يمكنك:',
	            step2Item1: 'التصفح حسب الفئة (إلكترونيات، مجوهرات، مركبات، إلخ)',
	            step2Item2: 'البحث عن عناصر محددة',
	            step2Item3: 'التصفية حسب نطاق السعر، الحالة، والمزيد',
	            step2Item4: 'عرض المزادات المميزة في الصفحة الرئيسية',
	            step2Cta: 'تصفح المزادات',
	            step3Title: 'عرض تفاصيل المزاد',
	            step3Text: 'انقر على أي مزاد لعرض التفاصيل الكاملة:',
	            step3Item1: 'صور عالية الجودة ووصف مفصل',
	            step3Item2: 'العرض الحالي وزيادة العرض',
	            step3Item3: 'الوقت المتبقي (عداد تنازلي مباشر)',
	            step3Item4: 'سجل العروض ومعلومات المزايدين',
	            step3Item5: 'معلومات البائع',
	            step4Title: 'قدّم عرضك',
	            step4Text: 'عندما تكون جاهزاً للمزايدة:',
	            step4Item1: 'أدخل مبلغ العرض (يجب ألا يقل عن الحد الأدنى للعرض)',
	            step4Item2: 'يمكنك تفعيل العرض التلقائي مع تحديد حد أقصى',
	            step4Item3: 'انقر على "تقديم عرض" للإرسال',
	            step4Item4: 'راقب التحديثات الفورية أثناء عروض الآخرين',
	            step4Tip: 'نصيحة: استخدم العرض التلقائي لزيادة عرضك تلقائياً حتى الحد الأقصى الذي تحدده عندما يتفوق الآخرون على عرضك.',
	            step5Title: 'الفوز والدفع',
	            step5Text: 'إذا فزت بالمزاد:',
	            step5Item1: 'ستتلقى إشعاراً عند انتهاء المزاد',
	            step5Item2: 'سيتم إنشاء فاتورة تلقائياً',
	            step5Item3: 'أكمل الدفع باستخدام طريقتك المفضلة',
	            step5Item4: 'نسّق عملية التوصيل أو الاستلام',
	            tipsTitle: 'نصائح للمزايدة',
	            tipsItem1: 'حدد ميزانية قصوى قبل المزايدة',
	            tipsItem2: 'استخدم العرض التلقائي للبقاء في المنافسة تلقائياً',
	            tipsItem3: 'اقرأ وصف العناصر بعناية',
	            tipsItem4: 'تحقق من تقييمات البائع ومراجعاته',
	            tipsItem5: 'راقب عداد الوقت المتبقي جيداً',
	            tipsItem6: 'قدّم عروضك مبكراً لتجنب ضغط اللحظات الأخيرة',
	            faqTitle: 'الأسئلة الشائعة',
	            faqQ1: 'هل يمكنني سحب العرض؟',
	            faqA1: 'العروض نهائية ولا يمكن سحبها. يرجى المزايدة بحذر وتقديم عروض أنت ملتزم بها.',
	            faqQ2: 'ماذا يحدث إذا تم تجاوز عرضي؟',
	            faqA2: 'ستتلقى إشعاراً. إذا كان العرض التلقائي مفعلاً، فسيقوم تلقائياً بتقديم عرض أعلى حتى الحد الأقصى الذي حددته.',
	            faqQ3: 'كيف يعمل العرض التلقائي؟',
	            faqA3: 'العرض التلقائي يزيد عرضك تلقائياً عندما يتفوق الآخرون على عرضك، حتى يصل إلى الحد الأقصى الذي حددته.',
	            faqQ4: 'ما هي الرسوم؟',
	            faqA4: 'توجد رسوم عرض بنسبة 1% على العروض الرابحة، بالإضافة إلى رسوم التوصيل حسب موقعك.',
	            ctaTitle: 'جاهز للبدء بالمزايدة؟',
	            ctaText: 'انضم إلى آلاف المزايدين واكتشف عروضاً رائعة!',
	            ctaPrimary: 'إنشاء حساب الآن',
	            ctaSecondary: 'تصفح المزادات'
	        },
			// Contact Us page
			contactPage: {
			    intro: 'تواصل معنا. نحن هنا لمساعدتك في أي أسئلة أو استفسارات.',
			    getInTouchTitle: 'تواصل معنا',
			    emailTitle: 'البريد الإلكتروني',
			    phoneTitle: 'الهاتف',
			    phoneHoursShort: 'الإثنين - الجمعة: 9:00 ص - 6:00 م',
			    addressTitle: 'العنوان',
			    addressLine1: '123 شارع المزاد',
			    addressLine2: 'مدينة المزايدة، BC 12345',
			    addressLine3: 'البلد',
			    businessHoursTitle: 'ساعات العمل',
			    hoursWeekdays: 'الإثنين - الجمعة: 9:00 ص - 6:00 م',
			    hoursSaturday: 'السبت: 10:00 ص - 4:00 م',
			    hoursSunday: 'الأحد: مغلق',
			    formTitle: 'أرسل لنا رسالة',
			    nameLabel: 'الاسم *',
			    emailLabel: 'البريد الإلكتروني *',
			    subjectLabel: 'الموضوع *',
			    subjectPlaceholder: 'اختر موضوعاً',
			    subjectGeneral: 'استفسار عام',
			    subjectSupport: 'دعم فني',
			    subjectBidding: 'أسئلة حول المزايدة',
			    subjectPayment: 'مشاكل الدفع',
			    subjectAccount: 'مشاكل الحساب',
			    subjectOther: 'أخرى',
			    messageLabel: 'الرسالة *',
			    submitButton: 'إرسال الرسالة'
			},
				// My Bids page
				myBidsPage: {
				    title: 'عروضي الرابحة',
				    subtitle: 'يعرض فقط المزادات التي فزت بها أو التي تتصدرها حالياً',
				    loading: 'جارٍ تحميل عروضك...',
				    noWinningTitle: 'ليس لديك أي عروض رابحة بعد.',
				    noWinningSubtitle: 'استمر في المزايدة للفوز بالمزادات المميزة!',
				    noBidsTitle: 'لم تقم بتقديم أي عروض بعد.',
				    browseAuctions: 'تصفح المزادات',
				    loadError: 'تعذر تحميل عروضك. يرجى المحاولة مرة أخرى.',
				    loadErrorShort: 'تعذر تحميل عروضك',
				    loginRequired: 'يرجى تسجيل الدخول لعرض عروضك',
				    unknownAuction: 'مزاد غير معروف',
				    unknownTime: 'وقت غير معروف',
				    currentLabel: 'العرض الحالي:',
				    auctionEndedBadge: 'انتهى المزاد',
				    statusWon: 'رابح',
				    statusWinning: 'متصدر',
				    statusOutbid: 'تمت المزايدة عليك',
				    autoBidBadge: 'مزايدة تلقائية'
					},
	    // Admin
        admin: {
            title: 'لوحة تحكم الإدارة',
            users: 'المستخدمون',
            auctions: 'المزادات',
            categories: 'الفئات',
            stats: 'الإحصائيات',
            totalUsers: 'إجمالي المستخدمين',
            totalAdmins: 'إجمالي المشرفين',
            totalAuctions: 'إجمالي المزادات',
            activeAuctions: 'المزادات النشطة',
            endedAuctions: 'المزادات المنتهية',
            totalBids: 'إجمالي العروض',
            recentUsers: 'المستخدمون الجدد'
        },
        // Messages
        messages: {
            serverError: 'لا يمكن الاتصال بالخادم! تأكد من أن الخادم الخلفي يعمل على المنفذ 5000.',
            unauthorized: 'غير مصرح لك بتنفيذ هذا الإجراء',
            notFound: 'المورد غير موجود',
            validationError: 'يرجى التحقق من إدخالك والمحاولة مرة أخرى',
            networkError: 'خطأ في الشبكة. يرجى التحقق من اتصالك.',
            genericError: 'حدث خطأ. يرجى المحاولة مرة أخرى لاحقاً.',
            invalidAuctionId: 'معرّف المزاد غير صحيح',
            loginRequired: 'يرجى تسجيل الدخول لتقديم عرض',
            auctionInactive: 'لم يعد هذا المزاد نشطاً',
            invalidVideoUrl: 'تنسيق رابط الفيديو غير صحيح',
            noFeaturedAuctions: 'لا توجد مزادات مميزة متاحة',
            linkCopied: 'تم نسخ الرابط إلى الحافظة! الصقه في التطبيق.',
            copyLinkManually: 'يرجى نسخ الرابط يدوياً',
            shareSuccess: 'تم المشاركة بنجاح!',
            shareFailed: 'فشلت المشاركة',
            errorRecordingShare: 'خطأ في تسجيل المشاركة. يرجى المحاولة مرة أخرى.',
            processing: 'جاري المعالجة...',
            photoUploaded: 'تم رفع الصورة بنجاح',
            passwordRequirementLength: '8 أحرف على الأقل',
            passwordRequirementLowercase: 'حرف صغير واحد',
            passwordRequirementUppercase: 'حرف كبير واحد',
            passwordRequirementNumber: 'رقم واحد',
            passwordRequirementSpecial: 'رمز خاص واحد (!@#$%^&*()_+-=[]{}|;:,.<>?)',
            passwordMustMeetRequirements: 'يجب أن تستوفي كلمة المرور جميع المتطلبات أعلاه',
            admin: 'الإدارة',
            howToBid: 'كيفية المزايدة',
            contactUs: 'اتصل بنا',
	            returnRequests: 'طلبات الإرجاع',
	            info: 'معلومات',
	            profilePhoto: 'صورة الملف الشخصي',
            uploadPhoto: 'رفع صورة',
            optional: 'اختياري',
            max5MB: 'حد أقصى 5MB، JPG/PNG'
        }
    }
};

// Current language (default: English)
let currentLanguage = localStorage.getItem('language') || 'en';

// RTL languages
const rtlLanguages = ['ar', 'ku'];

// Initialize i18n system
function initI18n() {
    // Set language from localStorage or default to English
    const savedLang = localStorage.getItem('language');
    if (savedLang && translations[savedLang]) {
        currentLanguage = savedLang;
    }
    
    // Apply language on page load
    applyLanguage(currentLanguage);
    
    // Update HTML lang attribute
    document.documentElement.lang = currentLanguage;
    
    // Apply RTL if needed
    applyRTL(currentLanguage);
}

// Apply language changes
function applyLanguage(lang) {
    if (!translations[lang]) {
        console.warn(`Language ${lang} not found, falling back to English`);
        lang = 'en';
    }
    
    currentLanguage = lang;
    localStorage.setItem('language', lang);
    
    // Update HTML lang attribute
    document.documentElement.lang = lang;
    
    // Update page title if translation exists
    const titleTranslation = getTranslation('home.title');
    if (titleTranslation && document.title) {
        // Only update if title matches expected pattern or contains 'ZUBID'
        if (document.title.includes('ZUBID') || !document.title.includes(' - ')) {
            document.title = titleTranslation;
        }
    }
    
    // Apply RTL if needed
    applyRTL(lang);
    
    // Translate all elements with data-i18n attribute
    document.querySelectorAll('[data-i18n]').forEach(element => {
        const key = element.getAttribute('data-i18n');
        const translation = getTranslation(key);
        if (translation) {
            if (element.tagName === 'INPUT' && element.type === 'submit') {
                element.value = translation;
            } else if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
                // Don't override placeholder if it's set via data-i18n-placeholder
                if (!element.hasAttribute('data-i18n-placeholder')) {
                    element.placeholder = translation;
                }
            } else {
                // Preserve HTML structure if it exists
                if (element.children.length === 0) {
                    element.textContent = translation;
                } else {
                    // If element has children, only update text nodes
                    const textNodes = [];
                    const walker = document.createTreeWalker(
                        element,
                        NodeFilter.SHOW_TEXT,
                        null,
                        false
                    );
                    let node;
                    while (node = walker.nextNode()) {
                        textNodes.push(node);
                    }
                    if (textNodes.length > 0) {
                        textNodes[0].textContent = translation;
                        // Remove other text nodes
                        for (let i = 1; i < textNodes.length; i++) {
                            textNodes[i].remove();
                        }
                    } else {
                        element.textContent = translation;
                    }
                }
            }
        }
    });
    
    // Translate placeholders
    document.querySelectorAll('[data-i18n-placeholder]').forEach(element => {
        const key = element.getAttribute('data-i18n-placeholder');
        const translation = getTranslation(key);
        if (translation) {
            element.placeholder = translation;
        }
    });
    
    // Translate title attributes
    document.querySelectorAll('[data-i18n-title]').forEach(element => {
        const key = element.getAttribute('data-i18n-title');
        const translation = getTranslation(key);
        if (translation) {
            element.title = translation;
        }
    });
    
    // Translate aria-label attributes
    document.querySelectorAll('[data-i18n-aria-label]').forEach(element => {
        const key = element.getAttribute('data-i18n-aria-label');
        const translation = getTranslation(key);
        if (translation) {
            element.setAttribute('aria-label', translation);
        }
    });
    
    // Translate option elements within select
    document.querySelectorAll('option[data-i18n]').forEach(element => {
        const key = element.getAttribute('data-i18n');
        const translation = getTranslation(key);
        if (translation) {
            element.textContent = translation;
        }
    });
    
    // Update language switcher display
    updateLanguageSwitcherDisplay(lang);
    
    // Force re-translation of dynamically added content
    // This helps with content loaded after initial page load
    setTimeout(() => {
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            const translation = getTranslation(key);
            if (translation) {
                if (element.tagName === 'INPUT' && element.type === 'submit') {
                    element.value = translation;
                } else if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
                    if (!element.hasAttribute('data-i18n-placeholder')) {
                        element.placeholder = translation;
                    }
                } else if (element.children.length === 0) {
                    element.textContent = translation;
                }
            }
        });
        
        document.querySelectorAll('[data-i18n-placeholder]').forEach(element => {
            const key = element.getAttribute('data-i18n-placeholder');
            const translation = getTranslation(key);
            if (translation) {
                element.placeholder = translation;
            }
        });
    }, 100);
    
    // Trigger custom event for other scripts to listen
    // This will allow other scripts to update their dynamic content
    document.dispatchEvent(new CustomEvent('languageChanged', { detail: { language: lang } }));
}

// Get translation by key (supports nested keys like 'nav.home')
function getTranslation(key) {
    const keys = key.split('.');
    let value = translations[currentLanguage];
    
    for (const k of keys) {
        if (value && typeof value === 'object' && k in value) {
            value = value[k];
        } else {
            return null;
        }
    }
    
    return typeof value === 'string' ? value : null;
}

// Translate function for use in JavaScript
function t(key, defaultValue = null) {
    const translation = getTranslation(key);
    return translation || defaultValue || key;
}

// Apply RTL styles
function applyRTL(lang) {
    const isRTL = rtlLanguages.includes(lang);
    document.documentElement.dir = isRTL ? 'rtl' : 'ltr';
    document.body.classList.toggle('rtl', isRTL);
    document.body.classList.toggle('ltr', !isRTL);
}

// Update language switcher display
function updateLanguageSwitcherDisplay(lang) {
    const langDisplay = document.getElementById('currentLangDisplay');
    if (langDisplay) {
        const langNames = {
            'en': 'EN',
            'ku': 'KU',
            'ar': 'AR'
        };
        langDisplay.textContent = langNames[lang] || 'EN';
    }
    
    // Update active language option
    document.querySelectorAll('.language-option').forEach(option => {
        option.classList.remove('active');
        if (option.getAttribute('data-lang') === lang) {
            option.classList.add('active');
        }
    });
}

// Toggle language dropdown
function toggleLanguageDropdown() {
    const switcher = document.getElementById('languageSwitcher');
    if (switcher) {
        switcher.classList.toggle('active');
    }
}

// Change language
function changeLang(lang) {
    if (translations[lang]) {
        applyLanguage(lang);
        // Close dropdown
        const switcher = document.getElementById('languageSwitcher');
        if (switcher) {
            switcher.classList.remove('active');
        }
    } else {
        console.error(`Language ${lang} not supported`);
    }
}

// Close language dropdown when clicking outside
document.addEventListener('click', function(event) {
    const switcher = document.getElementById('languageSwitcher');
    if (switcher && !switcher.contains(event.target)) {
        switcher.classList.remove('active');
    }
});

// Change language
function changeLanguage(lang) {
    changeLang(lang);
}

// Get current language
function getCurrentLanguage() {
    return currentLanguage;
}

// Get available languages
function getAvailableLanguages() {
    return Object.keys(translations).map(code => ({
        code,
        name: code === 'en' ? 'English' : code === 'ku' ? 'کوردی' : 'العربية'
    }));
}

// Initialize on DOM ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initI18n);
} else {
    initI18n();
}

// Export for use in other scripts
if (typeof window !== 'undefined') {
    window.i18n = {
        t,
        changeLanguage,
        changeLang,
        getCurrentLanguage,
        getAvailableLanguages,
        translations,
        init: initI18n
    };
    
    // Make functions globally available
    window.changeLang = changeLang;
    window.toggleLanguageDropdown = toggleLanguageDropdown;
}

