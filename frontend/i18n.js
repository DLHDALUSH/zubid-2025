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
            phonePlaceholder: '07501234567',
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
            pageTitle: 'How to Use ZUBID',
            intro: 'Learn how to use ZUBID - your complete guide to bidding, selling, and managing your account on our premium auction platform.',
            // Getting Started Section
            gettingStartedTitle: 'Getting Started',
            step1Title: 'Create Your Account',
            step1Text: 'Start by creating a free account on ZUBID. Click the "Sign Up" button in the navigation bar and fill in your details. You\'ll need to provide:',
            step1Item1: 'Username and email address',
            step1Item2: 'Secure password (8+ characters with letters and numbers)',
            step1Item3: 'Profile photo (optional but recommended)',
            step1Cta: 'Sign Up Now',
            step2Title: 'Browse Auctions',
            step2Text: 'Explore our wide selection of auctions. You can:',
            step2Item1: 'Browse by category (Electronics, Jewelry, Vehicles, Art, Fashion)',
            step2Item2: 'Search for specific items using the search bar',
            step2Item3: 'Filter by price range, status, and time remaining',
            step2Item4: 'View featured auctions on the homepage',
            step2Item5: 'Switch between grid and list view',
            step2Cta: 'Browse Auctions',
            step3Title: 'View Auction Details',
            step3Text: 'Click on any auction to see detailed information:',
            step3Item1: 'High-quality images with zoom capability',
            step3Item2: 'Current bid and minimum bid increment',
            step3Item3: 'Live countdown timer showing time remaining',
            step3Item4: 'Complete bid history and bidder information',
            step3Item5: 'Seller information and ratings',
            step3Item6: 'Share auction via social media or copy link',
            // Bidding Section
            biddingTitle: 'How to Bid',
            step4Title: 'Place Your Bid',
            step4Text: 'When you\'re ready to bid:',
            step4Item1: 'Enter your bid amount (must meet minimum bid requirement)',
            step4Item2: 'Enable auto-bid to automatically compete up to your max limit',
            step4Item3: 'Click "Place Bid" to submit your bid',
            step4Item4: 'Watch real-time updates as others bid',
            step4Item5: 'Get instant notifications when outbid',
            step4Tip: 'Pro Tip: Use auto-bid to automatically increase your bid up to your maximum limit when others outbid you. This way you won\'t miss out even when you\'re away!',
            step5Title: 'Win and Pay',
            step5Text: 'If you win the auction:',
            step5Item1: 'You\'ll receive an instant notification when the auction ends',
            step5Item2: 'An invoice will be generated automatically',
            step5Item3: 'Complete payment through secure methods',
            step5Item4: 'Track your order and arrange delivery',
            step5Item5: 'Leave a review after receiving your item',
            // Selling Section
            sellingTitle: 'How to Sell',
            sellStep1Title: 'Create an Auction',
            sellStep1Text: 'List your items for auction:',
            sellStep1Item1: 'Go to "My Account" > "Create Auction"',
            sellStep1Item2: 'Upload high-quality photos of your item',
            sellStep1Item3: 'Write a detailed description',
            sellStep1Item4: 'Set starting price and auction duration',
            sellStep1Item5: 'Choose the appropriate category',
            sellStep2Title: 'Manage Your Auctions',
            sellStep2Text: 'Keep track of your listings:',
            sellStep2Item1: 'View all your auctions in "My Auctions"',
            sellStep2Item2: 'Monitor bids and bidder activity',
            sellStep2Item3: 'Edit auction details if needed',
            sellStep2Item4: 'Respond to buyer questions',
            sellStep3Title: 'Complete the Sale',
            sellStep3Text: 'After your auction ends:',
            sellStep3Item1: 'Contact the winning bidder',
            sellStep3Item2: 'Arrange payment collection',
            sellStep3Item3: 'Ship the item or arrange pickup',
            sellStep3Item4: 'Mark as delivered when complete',
            // Account Management Section
            accountTitle: 'Managing Your Account',
            profileTitle: 'Your Profile',
            profileText: 'Customize your profile and manage settings:',
            profileItem1: 'Update your profile photo and personal info',
            profileItem2: 'Change your password securely',
            profileItem3: 'View your bidding history',
            profileItem4: 'Track won auctions and purchases',
            profileItem5: 'Manage notification preferences',
            myBidsTitle: 'My Bids',
            myBidsText: 'Track all your bidding activity:',
            myBidsItem1: 'View active bids on ongoing auctions',
            myBidsItem2: 'See auctions you\'ve won',
            myBidsItem3: 'Check outbid notifications',
            myBidsItem4: 'Cancel auto-bids if needed',
            paymentsTitle: 'Payments',
            paymentsText: 'Manage your financial transactions:',
            paymentsItem1: 'View pending and completed payments',
            paymentsItem2: 'Download invoices and receipts',
            paymentsItem3: 'Track payment history',
            paymentsItem4: 'Request returns if needed',
            // App Features Section
            featuresTitle: 'App Features',
            languageTitle: 'Language Selection',
            languageText: 'ZUBID supports multiple languages:',
            languageItem1: 'Click the globe icon (🌐) in the navigation bar',
            languageItem2: 'Choose from English, Kurdish (کوردی), or Arabic (العربية)',
            languageItem3: 'The entire app will switch to your selected language',
            languageItem4: 'Your preference is saved automatically',
            themeTitle: 'Dark/Light Mode',
            themeText: 'Switch between visual themes:',
            themeItem1: 'Click the sun/moon icon in the navigation bar',
            themeItem2: 'Dark mode is easier on the eyes at night',
            themeItem3: 'Your theme preference is saved automatically',
            notificationsTitle: 'Notifications',
            notificationsText: 'Stay updated on auction activity:',
            notificationsItem1: 'Get notified when you\'re outbid',
            notificationsItem2: 'Receive alerts when auctions you\'re watching end soon',
            notificationsItem3: 'Get instant notification when you win',
            notificationsItem4: 'Click the bell icon to view all notifications',
            // Tips Section
            tipsTitle: 'Bidding Tips',
            tipsItem1: 'Set a maximum budget before you start bidding',
            tipsItem2: 'Use auto-bid to stay competitive automatically',
            tipsItem3: 'Read item descriptions and view all photos carefully',
            tipsItem4: 'Check seller ratings and past transactions',
            tipsItem5: 'Watch the countdown timer - last minute bidding is intense!',
            tipsItem6: 'Bid early to show serious interest',
            tipsItem7: 'Enable notifications to never miss an update',
            // FAQ Section
            faqTitle: 'Frequently Asked Questions',
            faqQ1: 'Can I cancel or retract a bid?',
            faqA1: 'Bids are binding and cannot be retracted. Please bid carefully and only place bids you\'re committed to honor.',
            faqQ2: 'What happens if I\'m outbid?',
            faqA2: 'You\'ll receive an instant notification. If you have auto-bid enabled, it will automatically place a higher bid up to your maximum limit.',
            faqQ3: 'How does auto-bid work?',
            faqA3: 'Auto-bid automatically increases your bid by the minimum increment when others outbid you, up to your specified maximum amount. It\'s like having a bidding assistant!',
            faqQ4: 'What are the fees?',
            faqA4: 'Buyers pay a small 1% service fee on winning bids. Sellers may have listing fees depending on their account type.',
            faqQ5: 'How do I contact a seller?',
            faqA5: 'You can view seller information on the auction page. After winning, you\'ll receive the seller\'s contact details.',
            faqQ6: 'What if I don\'t receive my item?',
            faqA6: 'Use the Return Request feature in your account. Our support team will help resolve any issues.',
            faqQ7: 'How do I change the language?',
            faqA7: 'Click the globe icon (🌐) in the top navigation bar and select your preferred language.',
            faqQ8: 'Is my payment information secure?',
            faqA8: 'Yes, all transactions are secured with industry-standard encryption. We never store your full payment details.',
            // CTA Section
            ctaTitle: 'Ready to Start?',
            ctaText: 'Join thousands of buyers and sellers on ZUBID today!',
            ctaPrimary: 'Create Account',
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
            dashboard: 'Dashboard',
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
            recentUsers: 'New Users (7 days)',
            manageUsers: 'Manage Users',
            manageAuctions: 'Manage Auctions',
            manageCategories: 'Manage Categories',
            createAuction: 'Create Auction',
            editAuction: 'Edit Auction',
            deleteAuction: 'Delete Auction',
            approveAuction: 'Approve Auction',
            rejectAuction: 'Reject Auction',
            userDetails: 'User Details',
            makeAdmin: 'Make Admin',
            removeAdmin: 'Remove Admin',
            banUser: 'Ban User',
            unbanUser: 'Unban User',
            reports: 'Reports',
            settings: 'Settings',
            systemSettings: 'System Settings',
            siteSettings: 'Site Settings',
            pendingApproval: 'Pending Approval',
            approved: 'Approved',
            rejected: 'Rejected'
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
            auctions: 'مزایدەکان',
            myBids: 'مزایدەکانم',
            payments: 'پارەدانەکان',
            profile: 'پڕۆفایل',
            admin: 'بەڕێوەبەری',
            login: 'چوونەژوورەوە',
            signUp: 'تۆمارکردن',
            logout: 'دەرچوون',
            myAccount: 'هەژمارەکەم',
            createAuction: 'دروستکردنی مزایدە',
            myAuctions: 'مزایدەکانم'
        },
        // Common
        common: {
            search: 'گەڕان',
            searchPlaceholder: 'گەڕان بۆ مزایدە، کاڵا، پۆلەکان...',
            loading: 'چاوەڕوانبە...',
            error: 'هەڵە',
            success: 'سەرکەوتوو',
            cancel: 'پاشگەزبوونەوە',
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
            no: 'نەخێر',
            all: 'هەموو',
            view: 'بینین',
            details: 'وردەکاری',
            actions: 'کردارەکان',
            status: 'دۆخ',
            date: 'بەروار',
            time: 'کات',
            amount: 'بڕ',
            total: 'کۆی گشتی',
            filter: 'پاڵاوتن',
            sort: 'ڕیزکردن',
            apply: 'جێبەجێکردن',
            reset: 'ڕێکخستنەوە',
            clear: 'پاککردنەوە',
            select: 'هەڵبژاردن',
            required: 'پێویستە',
            optional: 'ئارەزوومەندانە',
            viewAll: 'بینینی هەموو'
        },
        // Homepage
        home: {
            title: 'زوبید - پلاتفۆرمی مزایدەی نوێ',
            browseCategories: 'گەڕان بە پۆلەکان',
            featuredAuctions: 'مزایدە تایبەتەکان',
            myAuctions: 'مزایدەکانم',
            myBids: 'مزایدەکانم',
            viewProfile: 'بینینی پڕۆفایل',
            viewAll: 'بینینی هەموو',
            welcome: 'بەخێربێیت بۆ زوبید',
            welcomeSubtitle: 'باشترین پلاتفۆرمی مزایدە بۆ کڕین و فرۆشتن',
            startBidding: 'دەستپێکردنی مزایدە',
            hotAuctions: 'مزایدە گەرمەکان',
            endingSoon: 'بە زووی کۆتایی دێت',
            newArrivals: 'نوێترینەکان',
            popularCategories: 'پۆلە بەناوبانگەکان'
        },
        // Authentication
        auth: {
            login: 'چوونەژوورەوە',
            signUp: 'تۆمارکردن',
            logout: 'دەرچوون',
            username: 'ناوی بەکارهێنەر',
            password: 'وشەی نهێنی',
            email: 'ئیمەیڵ',
            confirmPassword: 'دووبارەکردنەوەی وشەی نهێنی',
            forgotPassword: 'وشەی نهێنیت لەبیرکردووە؟',
            loginSuccess: 'بەسەرکەوتوویی چوویتەژوورەوە!',
            logoutSuccess: 'بەسەرکەوتوویی دەرچوویت!',
            registerSuccess: 'تۆمارکردن بەسەرکەوتوویی تەواوبوو!',
            loginFailed: 'چوونەژوورەوە سەرکەوتوو نەبوو. تکایە زانیاریەکانت بپشکنە.',
            registerFailed: 'تۆمارکردن سەرکەوتوو نەبوو.',
            usernameRequired: 'ناوی بەکارهێنەر پێویستە',
            passwordRequired: 'وشەی نهێنی پێویستە',
            emailRequired: 'ئیمەیڵ پێویستە',
            loggingIn: 'چاوەڕوانبە...',
            registering: 'تۆمارکردن...',
            rememberMe: 'بمهێڵەوە لە یاد',
            orContinueWith: 'یان بەردەوامبە لەگەڵ',
            dontHaveAccount: 'هەژمارت نییە؟',
            alreadyHaveAccount: 'هەژمارت هەیە؟'
        },
        // Registration
        register: {
            title: 'دروستکردنی هەژمار',
            createAccount: 'دروستکردنی هەژمار',
            subtitle: 'بەشداربە لە زوبید بۆ دەستپێکردنی مزایدە لەسەر کاڵا جوانەکان',
            username: 'ناوی بەکارهێنەر',
            email: 'ئیمەیڵ',
            password: 'وشەی نهێنی',
            confirmPassword: 'دووبارەکردنەوەی وشەی نهێنی',
            idNumber: 'ژمارەی ناسنامە',
            idNumberPassport: 'ژمارەی ناسنامە / پاسپۆرت',
            birthDate: 'بەرواری لەدایکبوون',
            address: 'ناونیشان',
            phone: 'ژمارەی مۆبایل',
            biometricVerification: 'پشتڕاستکردنەوەی ناسنامە',
            idCardFront: 'ڕووی پێشەوەی کارتی ناسنامە',
            idCardBack: 'ڕووی پشتەوەی کارتی ناسنامە',
            idCard: 'کارتی ناسنامە',
            selfie: 'وێنەی خۆت',
            capture: 'وێنەگرتن',
            retake: 'دووبارە وێنەگرتن',
            clickToChooseDate: 'کرتە بکە بۆ هەڵبژاردنی بەروار',
            selectBirthday: 'بەرواری لەدایکبوونت هەڵبژێرە',
            selectDateOfBirth: 'بەرواری لەدایکبوونت هەڵبژێرە',
            weakPassword: 'لاواز',
            mediumPassword: 'مامناوەند',
            strongPassword: 'بەهێز',
            accountInfo: 'زانیاری هەژمار',
            identityVerification: 'پشتڕاستکردنەوەی ناسنامە',
            contactInfo: 'زانیاری پەیوەندی',
            usernamePlaceholder: 'ناوی بەکارهێنەرێکی تایبەت هەڵبژێرە',
            emailPlaceholder: 'ئیمەیڵەکەت@نموونە.کۆم',
            passwordPlaceholder: 'وشەی نهێنیەکی بەهێز دروستبکە',
            idNumberPlaceholder: 'ژمارەی ناسنامەی نیشتیمانی یان پاسپۆرت بنووسە',
            phonePlaceholder: '+964 750 123 4567',
            addressPlaceholder: 'ناونیشانی تەواو بنووسە (شەقام، شار، پارێزگا، کۆدی پۆستە)',
            usernameHint: 'ئەمە ناوی نیشاندانەکەت دەبێت',
            emailHint: 'ئیمەیڵەکەت هەرگیز بەهاوبەشی ناکرێت',
            passwordHint: 'لانیکەم 8 پیت بەکاربهێنە لەگەڵ ژمارە و هێما',
            passwordHintShort: 'لانیکەم 8 پیت بەکاربهێنە',
            idNumberHint: 'ئەمە بۆ پشتڕاستکردنەوەی ناسنامە بەکاردێت',
            birthDateHint: 'بەرواری لەدایکبوونەکەت وەک لە کارتی ناسنامەکەتدا',
            biometricHint: 'کلیک بکە بۆ سکانکردنی هەردوو لای کارتی ناسنامەکەت و وێنەی خۆت',
            biometricHintShort: 'کلیک بکە بۆ سکانکردنی کارتی ناسنامە و وێنەی خۆت',
            scanIdSelfie: 'سکانی ناسنامە و وێنەی خۆت',
            idCardCaptured: '✅ کارتی ناسنامە گیرا',
            idCardFrontCaptured: '✅ ڕووی پێشەوەی ناسنامە',
            idCardBackCaptured: '✅ ڕووی پشتەوەی ناسنامە',
            selfieCaptured: '✅ وێنەی خۆت',
            scanIdCard: 'سکانکردنی کارتی ناسنامە',
            startCamera: 'دەستپێکردنی کامێرا',
            capturePhoto: 'وێنەگرتن',
            switchCamera: 'گۆڕینی کامێرا',
            cameraPlaceholder: 'کامێرا لێرە دەردەکەوێت',
            step1: 'هەنگاوی ١',
            step2: 'هەنگاوی ٢',
            step3: 'هەنگاوی ٣',
            stepIdFront: 'ڕووی پێشەوە',
            stepIdBack: 'ڕووی پشتەوە',
            stepSelfie: 'وێنەی خۆت',
            pending: 'چاوەڕوان',
            done: 'تەواوبوو - هەموو وێنەکان گیران',
            doneShort: 'تەواوبوو - هەردوو وێنە گیران',
            alreadyHaveAccount: 'هەژمارت هەیە؟',
            signIn: 'چوونەژوورەوە',
            required: 'پێویستە',
            phoneHint: 'ئەمە بۆ پەیوەندیکردن لەگەڵت دەربارەی مزایدەکانت',
            addressHint: 'پێویستە بۆ ناردن و وەرگرتنی کاڵاکان'
        },
        // Auctions
        auctions: {
            title: 'هەموو مزایدەکان',
            featured: 'مزایدە تایبەتەکان',
            noAuctions: 'هیچ مزایدەیەک نەدۆزرایەوە',
            noAuctionsMessage: 'هیچ مزایدەیەک نەدۆزرایەوە. هەوڵبدە پاڵاوتەکان بگۆڕیت.',
            currentBid: 'نرخی ئێستا',
            startingBid: 'نرخی دەستپێکردن',
            timeLeft: 'کاتی ماوە',
            timeRemaining: 'کاتی ماوە',
            bids: 'مزایدە',
            bidder: 'مزایدەکار',
            bidHistory: 'مێژووی مزایدە',
            placeBid: 'مزایدەکردن',
            placeABid: 'مزایدەکردن',
            bidAmount: 'بڕی مزایدە',
            yourBidAmount: 'بڕی مزایدەکەت',
            autoBid: 'مزایدەی خۆکار',
            enableAutoBid: 'مزایدەی خۆکار چالاک بکە (سنووری زۆرترین)',
            maxAutoBid: 'زۆرترین مزایدە',
            bidPlaced: 'مزایدە بەسەرکەوتوویی تۆمارکرا',
            bidFailed: 'مزایدەکردن سەرکەوتوو نەبوو',
            minBid: 'کەمترین مزایدە',
            minBidInfo: 'کەمترین مزایدە: $0.00',
            autoBidInfo: 'مزایدەی خۆکار خۆکارانە مزایدە دەکات تا ئەم بڕە',
            endingSoon: 'بەزووی کۆتایی دێت',
            ended: 'کۆتایی هات',
            active: 'چالاک',
            cancelled: 'هەڵوەشێنراوە',
            winner: 'بردوو',
            winning: 'سەرکەوتوو',
            outbid: 'مزایدەت تێپەڕێندرا',
            noBids: 'هیچ مزایدەیەک نییە',
            filterBy: 'پاڵاوتن بەپێی',
            sortBy: 'ڕیزکردن بەپێی',
            category: 'پۆل',
            allCategories: 'هەموو پۆلەکان',
            price: 'نرخ',
            priceHighToLow: 'نرخ (بەرز بۆ نزم)',
            minPrice: 'کەمترین نرخ',
            maxPrice: 'زۆرترین نرخ',
            timeLeftSort: 'کاتی ماوە',
            mostBids: 'زۆرترین مزایدە',
            bidCount: 'ژمارەی مزایدە',
            totalBids: 'کۆی مزایدەکان',
            gridView: 'نیشاندانی خشتەیی',
            listView: 'نیشاندانی لیستی',
            applyFilters: 'جێبەجێکردنی پاڵاوتن',
            reset: 'ڕێکخستنەوە',
            searchAuctions: 'گەڕان لە مزایدەکان...',
            loadingAuctions: 'بارکردنی مزایدەکان...',
            loadingDetails: 'بارکردنی وردەکاری...',
            description: 'وەسف',
            bidIncrement: 'بڕی زیادکردن',
            auctionEnded: 'ئەم مزایدەیە کۆتایی هاتووە.',
            winnerInfo: 'زانیاری بردوو',
            seller: 'فرۆشیار',
            sellerName: 'ناوی فرۆشیار',
            sellerEmail: 'ئیمەیڵی فرۆشیار',
            selectCategory: 'پۆلێک هەڵبژێرە',
            featureHomepage: 'ئەم مزایدەیە لە پەڕەی سەرەکی پیشان بدە',
            marketPrice: 'نرخی بازاڕ',
            images: 'وێنەکان',
            shareAuction: 'هاوبەشکردنی مزایدە',
            reportAuction: 'ڕاپۆرتکردنی مزایدە',
            viewDetails: 'بینینی وردەکاری',
            bidNow: 'ئێستا مزایدەبکە'
        },
        // Create Auction
        createAuction: {
            title: 'دروستکردنی مزایدە',
            createNewAuction: 'دروستکردنی مزایدەی نوێ',
            itemName: 'ناوی کاڵا',
            description: 'وەسف',
            startingBid: 'نرخی دەستپێکردن',
            startingBidLabel: 'نرخی دەستپێکردن ($)',
            bidIncrement: 'بڕی زیادکردن',
            bidIncrementLabel: 'بڕی زیادکردن ($)',
            endTime: 'کاتی کۆتایی',
            endDateAndTime: 'بەروار و کاتی کۆتایی',
            category: 'پۆل',
            selectCategory: 'پۆلێک هەڵبژێرە',
            images: 'وێنەکان',
            imageUrls: 'لینکی وێنەکان (هەر یەک لە دێڕێکی جیاواز)',
            imageUrlsPlaceholder: 'لینکی وێنەکان بنووسە، هەر یەک لە دێڕێکی جیاواز\nhttps://example.com/image1.jpg\nhttps://example.com/image2.jpg',
            imageUrlsHint: 'دەتوانیت لینکی وێنە زیاد بکەیت. دەتوانیت وێنەی میزبانکراوەکانی خۆت بەکاربهێنیت.',
            addImage: 'زیادکردنی وێنە',
            featured: 'مزایدەی تایبەت',
            featureHomepage: 'ئەم مزایدەیە لە پەڕەی سەرەکی پیشان بدە',
            create: 'دروستکردنی مزایدە',
            creating: 'دروستکردن...',
            success: 'مزایدە بەسەرکەوتوویی دروستکرا!',
            failed: 'دروستکردنی مزایدە سەرکەوتوو نەبوو',
            uploadImages: 'بارکردنی وێنەکان',
            dragDropImages: 'وێنەکان ڕابکێشە بۆ ئێرە یان کلیک بکە',
            maxImages: 'زۆرترین ژمارەی وێنە: 5'
        },
        // Profile
        profile: {
            title: 'پڕۆفایل',
            myProfile: 'پڕۆفایلەکەم',
            accountInfo: 'زانیاری هەژمار',
            username: 'ناوی بەکارهێنەر',
            email: 'ئیمەیڵ',
            idNumber: 'ژمارەی ناسنامە',
            birthDate: 'بەرواری لەدایکبوون',
            address: 'ناونیشان',
            phone: 'ژمارەی مۆبایل',
            role: 'ڕۆڵ',
            editProfile: 'دەستکاریکردنی پڕۆفایل',
            updateProfile: 'نوێکردنەوەی پڕۆفایل',
            saveChanges: 'پاشەکەوتکردنی گۆڕانکاریەکان',
            updating: 'نوێکردنەوە...',
            updateSuccess: 'پڕۆفایل بەسەرکەوتوویی نوێکرایەوە!',
            updateFailed: 'نوێکردنەوەی پڕۆفایل سەرکەوتوو نەبوو',
            myAuctions: 'مزایدەکانم',
            myBids: 'مزایدەکانم',
            totalAuctions: 'کۆی مزایدەکان',
            totalBids: 'کۆی مزایدەکان',
            loadingProfile: 'بارکردنی پڕۆفایل...',
            usernameCannotChange: 'ناوی بەکارهێنەر ناتوانرێت بگۆڕدرێت',
            phoneHint: 'ئەمە بۆ پەیوەندیکردن لەگەڵت دەربارەی مزایدەکانت',
            addressHint: 'پێویستە بۆ ناردن و وەرگرتنی کاڵاکان',
            changePassword: 'گۆڕینی وشەی نهێنی',
            currentPassword: 'وشەی نهێنی ئێستا',
            newPassword: 'وشەی نهێنی نوێ',
            confirmNewPassword: 'دووبارەکردنەوەی وشەی نهێنی نوێ',
            accountSettings: 'ڕێکخستنەکانی هەژمار',
            notifications: 'ئاگادارکردنەوەکان',
            privacy: 'تایبەتمەندی',
            security: 'ئاسایش'
        },
        // Payments
        payments: {
            title: 'پارەدانەکان',
            invoice: 'پسوولە',
            itemPrice: 'نرخی کاڵا',
            bidFee: 'کرێی مزایدە',
            deliveryFee: 'کرێی گەیاندن',
            totalAmount: 'کۆی گشتی',
            paymentMethod: 'شێوازی پارەدان',
            paymentStatus: 'دۆخی پارەدان',
            pending: 'چاوەڕوان',
            paid: 'پارەدراوە',
            failed: 'سەرکەوتوو نەبوو',
            cancelled: 'هەڵوەشێنراوە',
            cashOnDelivery: 'پارەدان لەکاتی گەیاندن',
            fibPayment: 'پارەدانی FIB',
            payNow: 'ئێستا پارەبدە',
            selectPaymentMethod: 'شێوازی پارەدان هەڵبژێرە',
            paymentSuccess: 'پارەدان بەسەرکەوتوویی تەواوبوو!',
            paymentFailed: 'پارەدان سەرکەوتوو نەبوو',
            paymentHistory: 'مێژووی پارەدان',
            noPayments: 'هیچ پارەدانێک نییە',
            transactionId: 'ژمارەی مامەڵە',
            paymentDate: 'بەرواری پارەدان',
            refund: 'گەڕاندنەوەی پارە',
            refundRequested: 'داواکاری گەڕاندنەوە',
            refundProcessing: 'گەڕاندنەوە لە پرۆسەدایە',
            refundCompleted: 'گەڕاندنەوە تەواوبوو'
        },
        // How to Bid page
        howToBidPage: {
            pageTitle: 'چۆن زوبید بەکاربهێنیت',
            intro: 'فێربە چۆن زوبید بەکاربهێنیت - ڕێنمایی تەواوت بۆ مزایدەکردن، فرۆشتن و بەڕێوەبردنی هەژمارەکەت لەسەر پلاتفۆرمی مزایدەی زوبید.',
            // Getting Started Section
            gettingStartedTitle: 'دەستپێکردن',
            step1Title: 'هەژمارەکەت دروستبکە',
            step1Text: 'لەگەڵ دروستکردنی هەژماری خۆڕایی لە زوبید دەستپێبکە. دوگمەی "تۆمارکردن" لەسەر شریتی سەرەوە بکە و زانیاریەکانت پڕبکەرەوە. دەبێت ئەمانە دابین بکەیت:',
            step1Item1: 'ناوی بەکارهێنەر و ئیمەیڵ',
            step1Item2: 'وشەی نهێنیەکی بەهێز (٨+ پیت لەگەڵ پیت و ژمارە)',
            step1Item3: 'وێنەی پڕۆفایل (ئارەزوومەندانە بەڵام پێشنیارکراو)',
            step1Cta: 'ئێستا تۆماربکە',
            step2Title: 'گەڕان لە مزایدەکان',
            step2Text: 'کۆمەڵە مزایدەی جۆراوجۆر بسەیرە. دەتوانیت:',
            step2Item1: 'بگەڕێیت بەدوای پۆلەکان (ئەلیکترۆنیات، زێوەر، ئۆتۆمبێل، هونەر، جلوبەرگ)',
            step2Item2: 'بگەڕێیت بەدوای کاڵای دیاریکراو بە شریتی گەڕان',
            step2Item3: 'پاڵاوتن بکە بە نرخ، دۆخ و کاتی ماوە',
            step2Item4: 'مزایدە تایبەتەکان لە پەڕەی سەرەکی ببینە',
            step2Item5: 'گۆڕان لە نێوان دیمەنی تۆڕ و لیست',
            step2Cta: 'گەڕان لە مزایدەکان',
            step3Title: 'بینینی وردەکاری مزایدە',
            step3Text: 'کلیک لەسەر هەر مزایدەیەک بکە بۆ بینینی زانیاری ورد:',
            step3Item1: 'وێنەی بەرزکوالیتی بە توانای گەورەکردن',
            step3Item2: 'نرخی ئێستا و کەمترین بڕی زیادکردن',
            step3Item3: 'کاتژمێرەری ڕاستەوخۆ کە کاتی ماوە نیشان دەدات',
            step3Item4: 'مێژووی تەواوی مزایدە و زانیاری مزایدەکاران',
            step3Item5: 'زانیاری فرۆشیار و هەڵسەنگاندنەکان',
            step3Item6: 'هاوبەشکردنی مزایدە لە تۆڕە کۆمەڵایەتییەکان یان کۆپیکردنی لینک',
            // Bidding Section
            biddingTitle: 'چۆن مزایدە بکەیت',
            step4Title: 'مزایدەکەت بنووسە',
            step4Text: 'کاتێک ئامادەیت بۆ مزایدەکردن:',
            step4Item1: 'بڕی مزایدەکەت بنووسە (دەبێت کەمترین مزایدە بپڕێنێت)',
            step4Item2: 'مزایدەی خۆکار چالاک بکە بۆ ڕکابەری خۆکارانە تا سنووری زۆرترینت',
            step4Item3: 'دوگمەی "مزایدەکردن" بکە بۆ ناردن',
            step4Item4: 'نوێکاریەکانی مزایدەکان بەکاتی ڕاستەوخۆ ببینە',
            step4Item5: 'ئاگاداری کاتی دەکرێیتەوە کاتێک کەسێک مزایدەی زیاتر دەنووسێت',
            step4Tip: 'ڕاوێژی پیشەیی: مزایدەی خۆکار بەکاربهێنە بۆ زیادکردنی مزایدەکانت خۆکارانە تا سنووری دیاریکراوەکەت ئەگەر کەسێکی تر مزایدەی زیاتر بکات. بەم شێوەیە مزایدەکان لەدەست نادەیت تەنانەت کاتێک نیت!',
            step5Title: 'بردن و پارەدان',
            step5Text: 'ئەگەر بردوو بیت لە مزایدە:',
            step5Item1: 'ئاگاداری کاتی دەکرێیتەوە کاتێک مزایدەکە کۆتایی دێت',
            step5Item2: 'پسوولە خۆکارانە دروست دەکرێت',
            step5Item3: 'پارەدان بکە بە ڕێگای پارستراو',
            step5Item4: 'چاودێری بکە لە داواکارییەکەت و ڕێک بخە بۆ گەیاندن',
            step5Item5: 'هەڵسەنگاندن جێبهێڵە دوای وەرگرتنی کاڵاکەت',
            // Selling Section
            sellingTitle: 'چۆن بفرۆشیت',
            sellStep1Title: 'مزایدەیەک دروستبکە',
            sellStep1Text: 'کاڵاکانت بۆ مزایدە تۆماربکە:',
            sellStep1Item1: 'بڕۆ بۆ "هەژمارەکەم" > "دروستکردنی مزایدە"',
            sellStep1Item2: 'وێنەی بەرزکوالیتی کاڵاکەت بار بکە',
            sellStep1Item3: 'وەسفێکی تەواو بنووسە',
            sellStep1Item4: 'نرخی دەستپێکردن و ماوەی مزایدە دیاربکە',
            sellStep1Item5: 'پۆلی گونجاو هەڵبژێرە',
            sellStep2Title: 'مزایدەکانت بەڕێوەببە',
            sellStep2Text: 'چاودێری لیستەکانت بکە:',
            sellStep2Item1: 'هەموو مزایدەکانت ببینە لە "مزایدەکانم"',
            sellStep2Item2: 'چاودێری مزایدەکان و چالاکی مزایدەکاران بکە',
            sellStep2Item3: 'وردەکاری مزایدە دەستکاری بکە ئەگەر پێویست بوو',
            sellStep2Item4: 'وەڵامی پرسیارەکانی کڕیاران بدەوە',
            sellStep3Title: 'فرۆشتنەکە تەواو بکە',
            sellStep3Text: 'دوای کۆتایی مزایدەکەت:',
            sellStep3Item1: 'پەیوەندی بکە بە بردووەکە',
            sellStep3Item2: 'ڕێکخستن بکە بۆ وەرگرتنی پارە',
            sellStep3Item3: 'کاڵا بنێرە یان ڕێکبخە بۆ وەرگرتن',
            sellStep3Item4: 'وەک گەیاندرا نیشانی بکە کاتێک تەواو بوو',
            // Account Management Section
            accountTitle: 'بەڕێوەبردنی هەژمارەکەت',
            profileTitle: 'پڕۆفایلەکەت',
            profileText: 'پڕۆفایلەکەت تایبەتمەند بکە و ڕێکخستنەکان بەڕێوەببە:',
            profileItem1: 'وێنەی پڕۆفایل و زانیاری کەسیت نوێ بکەوە',
            profileItem2: 'وشەی نهێنیت بەشێوەیەکی پارستراو بگۆڕە',
            profileItem3: 'مێژووی مزایدەکردنت ببینە',
            profileItem4: 'چاودێری مزایدە بردووەکان و کڕینەکانت بکە',
            profileItem5: 'ڕێکخستنەکانی ئاگادارکردنەوە بەڕێوەببە',
            myBidsTitle: 'مزایدەکانم',
            myBidsText: 'چاودێری هەموو چالاکی مزایدەکردنت بکە:',
            myBidsItem1: 'مزایدە چالاکەکان لەسەر مزایدەکانی بەردەوام ببینە',
            myBidsItem2: 'مزایدەکان ببینە کە بردوویانت',
            myBidsItem3: 'ئاگادارکردنەوەکانی مزایدەی زیاتر بپشکنە',
            myBidsItem4: 'مزایدە خۆکارەکان هەڵبوەشێنەوە ئەگەر پێویست بوو',
            paymentsTitle: 'پارەدانەکان',
            paymentsText: 'مامەڵە داراییەکانت بەڕێوەببە:',
            paymentsItem1: 'پارەدانە چاوەڕوان و تەواوبووەکان ببینە',
            paymentsItem2: 'پسوولە و وەسڵەکان دابەزێنە',
            paymentsItem3: 'مێژووی پارەدان چاودێری بکە',
            paymentsItem4: 'داواکاری گەڕاندنەوە بکە ئەگەر پێویست بوو',
            // App Features Section
            featuresTitle: 'تایبەتمەندیەکانی ئاپ',
            languageTitle: 'هەڵبژاردنی زمان',
            languageText: 'زوبید چەندین زمان پاڵپشتی دەکات:',
            languageItem1: 'ئایکۆنی گۆی زەوی (🌐) لە شریتی سەرەوە بکە',
            languageItem2: 'هەڵبژێرە لە ئینگلیزی، کوردی یان عەرەبی',
            languageItem3: 'هەموو ئاپەکە دەگۆڕێت بۆ زمانی هەڵبژاردراوت',
            languageItem4: 'ئارەزووەکەت خۆکارانە پاشەکەوت دەکرێت',
            themeTitle: 'دۆخی تاریک/ڕووناک',
            themeText: 'گۆڕان لە نێوان تەم بینراوەکان:',
            themeItem1: 'ئایکۆنی خۆر/مانگ لە شریتی سەرەوە بکە',
            themeItem2: 'دۆخی تاریک ئاسانترە بۆ چاو لە شەو',
            themeItem3: 'ئارەزووی تەمەکەت خۆکارانە پاشەکەوت دەکرێت',
            notificationsTitle: 'ئاگادارکردنەوەکان',
            notificationsText: 'هەمیشە لەسەر چالاکی مزایدە نوێبە:',
            notificationsItem1: 'ئاگادار دەکرێیتەوە کاتێک کەسێک مزایدەی زیاتر دەنووسێت',
            notificationsItem2: 'ئاگاداری وەردەگریت کاتێک مزایدەکانی چاودێرکراو نزیکی کۆتاییت',
            notificationsItem3: 'ئاگاداری کاتی وەردەگریت کاتێک دەبەیتەوە',
            notificationsItem4: 'ئایکۆنی زەنگ بکە بۆ بینینی هەموو ئاگادارکردنەوەکان',
            // Tips Section
            tipsTitle: 'ڕاوێژەکانی مزایدەکردن',
            tipsItem1: 'بڕی بودجەی زۆرترین دیاربکە پێش دەستپێکردنی مزایدەکردن',
            tipsItem2: 'مزایدەی خۆکار بەکاربهێنە بۆ ماندوونەبوون لە ڕکابەری خۆکارانە',
            tipsItem3: 'وەسفی کاڵا بخوێنەوە و هەموو وێنەکان بەوریایی ببینە',
            tipsItem4: 'هەڵسەنگاندن و مامەڵەکانی پێشووی فرۆشیار بپشکنە',
            tipsItem5: 'کاتژمێرەکە چاودێری بکە - مزایدەی کاتی کۆتا زۆر توند دەبێت!',
            tipsItem6: 'زوو مزایدە بکە بۆ نیشاندانی حەزی جدی',
            tipsItem7: 'ئاگادارکردنەوەکان چالاک بکە بۆ نەچوونەدەرەوەی هیچ نوێکارییەک',
            // FAQ Section
            faqTitle: 'پرسیارە باوەکان',
            faqQ1: 'دەتوانم مزایدەکەم هەڵبوەشێنمەوە؟',
            faqA1: 'مزایدەکان پابەندکەرن و ناتوانرێت هەڵبوەشێنرێنەوە. تکایە بەوریایی مزایدە بکە و تەنها مزایدەیەک بدە کە پابەندی ڕێزگرتنی.',
            faqQ2: 'ئەگەر کەسێکی تر مزایدەی زیاتر بکات چی دەبێت؟',
            faqA2: 'ئاگاداری کاتی وەردەگریت. ئەگەر مزایدەی خۆکار چالاکت کردووە، خۆکارانە مزایدەی بەرزتر دەنووسێت تا سنووری دیاریکراوەکەت.',
            faqQ3: 'مزایدەی خۆکار چۆن کاردەکات؟',
            faqA3: 'مزایدەی خۆکار خۆکارانە مزایدەکەت زیاد دەکات بە کەمترین بڕ کاتێک کەسێکی تر مزایدەی زیاتر دەنووسێت، تا ئەو بڕەی دیاریکراوە. وەک یارمەتیدەری مزایدەکردن وایە!',
            faqQ4: 'کرێکان چەندن؟',
            faqA4: 'کڕیاران کرێی خزمەتگوزاری بچووکی ١٪ دەدەن لەسەر مزایدەکانی بردن. فرۆشیاران لەوانەیە کرێی لیستکردن هەبێت بەپێی جۆری هەژمارەکەیان.',
            faqQ5: 'چۆن پەیوەندی بکەم بە فرۆشیارێک؟',
            faqA5: 'دەتوانیت زانیاری فرۆشیار ببینیت لە پەڕەی مزایدە. دوای بردن، زانیاری پەیوەندیکردنی فرۆشیار وەردەگریت.',
            faqQ6: 'ئەگەر کاڵاکەم وەرنەگرت چی؟',
            faqA6: 'تایبەتمەندی داواکاری گەڕاندنەوە لە هەژمارەکەت بەکاربهێنە. تیمی پاڵپشتیمان یارمەتیت دەدات بۆ چارەسەرکردنی هەر کێشەیەک.',
            faqQ7: 'چۆن زمان بگۆڕم؟',
            faqA7: 'ئایکۆنی گۆی زەوی (🌐) لە شریتی سەرەوە بکە و زمانی حەزکراوت هەڵبژێرە.',
            faqQ8: 'ئایا زانیاری پارەدانەکەم پارستراوە؟',
            faqA8: 'بەڵێ، هەموو مامەڵەکان بە شێوازی شفرکردنی پیشەسازی پارستراون. ئێمە هەرگیز زانیاری تەواوی پارەدانەکەت پاشەکەوت ناکەین.',
            // CTA Section
            ctaTitle: 'ئامادەیت بۆ دەستپێکردن؟',
            ctaText: 'ئەمڕۆ بەشداربە لەگەڵ هەزاران کڕیار و فرۆشیار لە زوبید!',
            ctaPrimary: 'دروستکردنی هەژمار',
            ctaSecondary: 'گەڕان لە مزایدەکان'
        },
        // Contact Us page
        contactPage: {
            intro: 'پەیوەندیمان پێوەبکە. ئێمە لێرەین بۆ یارمەتیدانت لە هەر پرسیار و نیگەرانیەک.',
            getInTouchTitle: 'پەیوەندیمان پێوەبکە',
            emailTitle: 'ئیمەیڵ',
            phoneTitle: 'ژمارەی مۆبایل',
            phoneHoursShort: 'شەممە - پێنجشەممە: 9:00 - 18:00',
            addressTitle: 'ناونیشان',
            addressLine1: 'شەقامی 60 مەتری',
            addressLine2: 'هەولێر، هەرێمی کوردستان',
            addressLine3: 'عێراق',
            businessHoursTitle: 'کاتەکانی کارکردن',
            hoursWeekdays: 'شەممە - پێنجشەممە: 9:00 - 18:00',
            hoursSaturday: 'هەینی: 10:00 - 14:00',
            hoursSunday: 'یەکشەممە: داخراوە',
            formTitle: 'پەیامێک بنێرە بۆ ئێمە',
            nameLabel: 'ناو *',
            emailLabel: 'ئیمەیڵ *',
            subjectLabel: 'بابەتی پەیام *',
            subjectPlaceholder: 'بابەتێک هەڵبژێرە',
            subjectGeneral: 'پرسیاری گشتی',
            subjectSupport: 'پاڵپشتی تەکنیکی',
            subjectBidding: 'پرسیاری مزایدەکردن',
            subjectPayment: 'کێشەکانی پارەدان',
            subjectAccount: 'کێشەکانی هەژمار',
            subjectOther: 'هیتر',
            messageLabel: 'پەیام *',
            submitButton: 'ناردنی پەیام',
            messagePlaceholder: 'پەیامەکەت لێرە بنووسە...',
            sendSuccess: 'پەیامەکەت بەسەرکەوتوویی نێردرا!',
            sendFailed: 'ناردنی پەیام سەرکەوتوو نەبوو'
        },
        // My Bids page
        myBidsPage: {
            title: 'مزایدەکانم',
            subtitle: 'تەنها ئەو مزایدانە پیشان دەدرێن کە بردووت یان ئێستا پێش دەچیت',
            loading: 'مزایدەکانت دەبارێن...',
            noWinningTitle: 'هێشتا هیچ مزایدەیەکت نەبردووە.',
            noWinningSubtitle: 'بەردەوامبە لە مزایدەکردن بۆ بردنی کاڵا جوانەکان!',
            noBidsTitle: 'هێشتا هیچ مزایدەیەکت نەکردووە.',
            browseAuctions: 'گەڕان لە مزایدەکان',
            loadError: 'نەتوانرا مزایدەکانت باربکرێن. تکایە دووبارە هەوڵبدە.',
            loadErrorShort: 'نەتوانرا مزایدەکانت باربکرێن',
            loginRequired: 'تکایە بچۆرەژوورەوە بۆ بینینی مزایدەکانت',
            unknownAuction: 'مزایدەی نەزانراو',
            unknownTime: 'کاتی نەزانراو',
            currentLabel: 'نرخی ئێستا:',
            auctionEndedBadge: 'مزایدە کۆتایی هات',
            statusWon: 'بردوو',
            statusWinning: 'پێش دەچیت',
            statusOutbid: 'مزایدەکەی تر بەرزترە',
            autoBidBadge: 'مزایدەی خۆکار'
        },
        // Admin
        admin: {
            title: 'داشبۆردی بەڕێوەبەری',
            dashboard: 'داشبۆرد',
            users: 'بەکارهێنەران',
            auctions: 'مزایدەکان',
            categories: 'پۆلەکان',
            stats: 'ئامارەکان',
            totalUsers: 'کۆی بەکارهێنەران',
            totalAdmins: 'کۆی بەڕێوەبەران',
            totalAuctions: 'کۆی مزایدەکان',
            activeAuctions: 'مزایدەی چالاک',
            endedAuctions: 'مزایدەی کۆتایی هاتوو',
            totalBids: 'کۆی مزایدەکان',
            recentUsers: 'بەکارهێنەری نوێ (7 ڕۆژ)',
            manageUsers: 'بەڕێوەبردنی بەکارهێنەران',
            manageAuctions: 'بەڕێوەبردنی مزایدەکان',
            manageCategories: 'بەڕێوەبردنی پۆلەکان',
            createAuction: 'دروستکردنی مزایدە',
            editAuction: 'دەستکاریکردنی مزایدە',
            deleteAuction: 'سڕینەوەی مزایدە',
            approveAuction: 'پەسەندکردنی مزایدە',
            rejectAuction: 'ڕەتکردنەوەی مزایدە',
            userDetails: 'وردەکاری بەکارهێنەر',
            makeAdmin: 'بکەرە بەڕێوەبەر',
            removeAdmin: 'لابردنی بەڕێوەبەری',
            banUser: 'قەدەغەکردنی بەکارهێنەر',
            unbanUser: 'لابردنی قەدەغە',
            reports: 'ڕاپۆرتەکان',
            settings: 'ڕێکخستنەکان',
            systemSettings: 'ڕێکخستنەکانی سیستەم',
            siteSettings: 'ڕێکخستنەکانی ماڵپەڕ',
            pendingApproval: 'چاوەڕوانی پەسەندکردن',
            approved: 'پەسەندکراو',
            rejected: 'ڕەتکراوەتەوە'
        },
        // Messages
        messages: {
            serverError: 'ناتوانیت بگەیتە سێرڤەر! دڵنیاببەوە کە سێرڤەر لە پۆرتی 5000 کاردەکات.',
            unauthorized: 'تۆ مۆڵەتت نییە بۆ ئەم کارە',
            notFound: 'سەرچاوەکە نەدۆزرایەوە',
            validationError: 'تکایە زانیاریەکانت بپشکنە و دووبارە هەوڵبدە',
            networkError: 'هەڵەی تۆڕ. تکایە پەیوەندیەکەت بپشکنە.',
            genericError: 'هەڵەیەک ڕوویدا. تکایە دواتر هەوڵبدەوە.',
            invalidAuctionId: 'ژمارەی مزایدە نادروستە',
            loginRequired: 'تکایە بچۆرەژوورەوە بۆ مزایدەکردن',
            auctionInactive: 'ئەم مزایدەیە چیتر چالاک نییە',
            invalidVideoUrl: 'شێوازی لینکی ڤیدیۆ نادروستە',
            noFeaturedAuctions: 'هیچ مزایدەیەکی تایبەت بەردەست نییە',
            linkCopied: 'لینک کۆپیکرا بۆ کلیپبۆرد!',
            copyLinkManually: 'تکایە لینکەکە بەدەستی کۆپیبکە',
            shareSuccess: 'بەسەرکەوتوویی هاوبەشکرا!',
            shareFailed: 'هاوبەشکردن سەرکەوتوو نەبوو',
            errorRecordingShare: 'هەڵە لە تۆمارکردنی هاوبەشکردندا. تکایە دووبارە هەوڵبدەوە.',
            processing: 'چاوەڕوانبە...',
            photoUploaded: 'وێنە بەسەرکەوتوویی بارکرا',
            passwordRequirementLength: 'لانیکەم 8 پیت',
            passwordRequirementLowercase: 'یەک پیتی بچووک',
            passwordRequirementUppercase: 'یەک پیتی گەورە',
            passwordRequirementNumber: 'یەک ژمارە',
            passwordRequirementSpecial: 'یەک هێمای تایبەت (!@#$%^&*)',
            passwordMustMeetRequirements: 'وشەی نهێنی دەبێت هەموو پێویستییەکان بپڕێت',
            admin: 'بەڕێوەبەری',
            howToBid: 'چۆن مزایدە بکەیت',
            contactUs: 'پەیوەندیمان پێوەبکە',
            returnRequests: 'داواکاری گەڕاندنەوە',
            info: 'زانیاری',
            profilePhoto: 'وێنەی پڕۆفایل',
            uploadPhoto: 'بارکردنی وێنە',
            optional: 'ئارەزوومەندانە',
            max5MB: 'زۆرترین 5MB، JPG/PNG',
            confirmDelete: 'دڵنیایت لە سڕینەوە؟',
            deleteSuccess: 'بەسەرکەوتوویی سڕایەوە',
            deleteFailed: 'سڕینەوە سەرکەوتوو نەبوو',
            updateSuccess: 'بەسەرکەوتوویی نوێکرایەوە',
            updateFailed: 'نوێکردنەوە سەرکەوتوو نەبوو',
            createSuccess: 'بەسەرکەوتوویی دروستکرا',
            createFailed: 'دروستکردن سەرکەوتوو نەبوو',
            welcome: 'بەخێربێیت',
            goodbye: 'بەخێر',
            thankYou: 'سوپاس'
        },
        // Return Requests
        returnRequests: {
            title: 'داواکاری گەڕاندنەوە',
            requestReturn: 'داواکاری گەڕاندنەوە',
            reason: 'هۆکار',
            description: 'وەسف',
            status: 'دۆخ',
            pending: 'چاوەڕوان',
            approved: 'پەسەندکراو',
            rejected: 'ڕەتکراوەتەوە',
            noRequests: 'هیچ داواکاریەکی گەڕاندنەوە نییە',
            submitRequest: 'ناردنی داواکاری',
            selectReason: 'هۆکارێک هەڵبژێرە',
            reasonDamaged: 'کاڵا زیانی پێگەیشتووە',
            reasonWrongItem: 'کاڵای هەڵە نێردراوە',
            reasonNotAsDescribed: 'وەک وەسفەکە نییە',
            reasonOther: 'هۆکاری تر'
        },
        // My Auctions
        myAuctions: {
            title: 'مزایدەکانم',
            active: 'چالاک',
            ended: 'کۆتایی هاتوو',
            pending: 'چاوەڕوان',
            noAuctions: 'هیچ مزایدەیەکت نییە',
            createFirst: 'یەکەم مزایدەکەت دروستبکە',
            totalEarnings: 'کۆی داهات',
            totalSold: 'کۆی فرۆشراو'
        },
        // Footer
        footer: {
            aboutUs: 'دەربارەی ئێمە',
            termsOfService: 'مەرجەکانی خزمەتگوزاری',
            privacyPolicy: 'سیاسەتی تایبەتمەندی',
            helpCenter: 'ناوەندی یارمەتی',
            followUs: 'بەدوایماندا بێ',
            copyright: '© 2025 زوبید. هەموو مافەکان پارێزراون.',
            quickLinks: 'لینکە خێراکان',
            support: 'پاڵپشتی',
            legal: 'یاسایی'
        },
        // Categories
        categories: {
            electronics: 'ئەلیکترۆنیات',
            vehicles: 'ئۆتۆمبێل',
            jewelry: 'زێوەر',
            fashion: 'جلوبەرگ',
            art: 'هونەر',
            collectibles: 'کۆکراوەکان',
            realEstate: 'خانووبەرە',
            sports: 'وەرزش',
            other: 'هیتر'
        }
    },
    ar: {
        // Navigation
        nav: {
            home: 'الرئيسية',
            auctions: 'المزادات',
            myBids: 'مزاداتي',
            payments: 'المدفوعات',
            profile: 'الملف الشخصي',
            admin: 'لوحة التحكم',
            login: 'تسجيل الدخول',
            signUp: 'إنشاء حساب',
            logout: 'تسجيل الخروج',
            myAccount: 'حسابي',
            createAuction: 'إنشاء مزاد',
            myAuctions: 'مزاداتي'
        },
        // Common
        common: {
            search: 'بحث',
            searchPlaceholder: 'ابحث عن المزادات، السلع، الفئات...',
            loading: 'جاري التحميل...',
            error: 'خطأ',
            success: 'نجاح',
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
            no: 'لا',
            all: 'الكل',
            view: 'عرض',
            details: 'التفاصيل',
            actions: 'الإجراءات',
            status: 'الحالة',
            date: 'التاريخ',
            time: 'الوقت',
            amount: 'المبلغ',
            total: 'المجموع',
            filter: 'تصفية',
            sort: 'ترتيب',
            apply: 'تطبيق',
            reset: 'إعادة تعيين',
            clear: 'مسح',
            select: 'اختيار',
            required: 'مطلوب',
            optional: 'اختياري',
            viewAll: 'عرض الكل'
        },
        // Homepage
        home: {
            title: 'زوبيد - منصة المزادات الحديثة',
            browseCategories: 'تصفح الفئات',
            featuredAuctions: 'المزادات المميزة',
            myAuctions: 'مزاداتي',
            myBids: 'مزاداتي',
            viewProfile: 'عرض الملف الشخصي',
            viewAll: 'عرض الكل',
            welcome: 'مرحباً بك في زوبيد',
            welcomeSubtitle: 'أفضل منصة مزادات للشراء والبيع',
            startBidding: 'ابدأ المزايدة',
            hotAuctions: 'المزادات الساخنة',
            endingSoon: 'تنتهي قريباً',
            newArrivals: 'وصل حديثاً',
            popularCategories: 'الفئات الشائعة'
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
            loggingIn: 'جاري تسجيل الدخول...',
            registering: 'جاري التسجيل...',
            rememberMe: 'تذكرني',
            orContinueWith: 'أو تابع مع',
            dontHaveAccount: 'ليس لديك حساب؟',
            alreadyHaveAccount: 'لديك حساب بالفعل؟'
        },
        // Registration
        register: {
            title: 'إنشاء حساب',
            createAccount: 'إنشاء حساب جديد',
            subtitle: 'انضم إلى زوبيد لبدء المزايدة على السلع الرائعة',
            username: 'اسم المستخدم',
            email: 'البريد الإلكتروني',
            password: 'كلمة المرور',
            confirmPassword: 'تأكيد كلمة المرور',
            idNumber: 'رقم الهوية',
            idNumberPassport: 'رقم الهوية / جواز السفر',
            birthDate: 'تاريخ الميلاد',
            address: 'العنوان',
            phone: 'رقم الجوال',
            biometricVerification: 'التحقق من الهوية',
            idCardFront: 'وجه بطاقة الهوية',
            idCardBack: 'ظهر بطاقة الهوية',
            idCard: 'بطاقة الهوية',
            selfie: 'صورة شخصية',
            capture: 'التقاط',
            retake: 'إعادة التقاط',
            clickToChooseDate: 'انقر لاختيار التاريخ',
            selectBirthday: 'اختر تاريخ ميلادك',
            selectDateOfBirth: 'اختر تاريخ ميلادك',
            weakPassword: 'ضعيفة',
            mediumPassword: 'متوسطة',
            strongPassword: 'قوية',
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
            required: 'مطلوب',
            phoneHint: 'سيتم استخدامه للتواصل معك بشأن مزاداتك',
            addressHint: 'مطلوب لشحن واستلام السلع'
        },
        // Auctions
        auctions: {
            title: 'جميع المزادات',
            featured: 'المزادات المميزة',
            noAuctions: 'لم يتم العثور على مزادات',
            noAuctionsMessage: 'لم يتم العثور على مزادات. حاول تعديل الفلاتر.',
            currentBid: 'السعر الحالي',
            startingBid: 'السعر الابتدائي',
            timeLeft: 'الوقت المتبقي',
            timeRemaining: 'الوقت المتبقي',
            bids: 'مزايدات',
            bidder: 'المزايد',
            bidHistory: 'سجل المزايدات',
            placeBid: 'قدم مزايدة',
            placeABid: 'قدم مزايدة',
            bidAmount: 'مبلغ المزايدة',
            yourBidAmount: 'مبلغ مزايدتك',
            autoBid: 'مزايدة تلقائية',
            enableAutoBid: 'تفعيل المزايدة التلقائية (الحد الأقصى)',
            maxAutoBid: 'الحد الأقصى للمزايدة',
            bidPlaced: 'تم تقديم المزايدة بنجاح',
            bidFailed: 'فشل تقديم المزايدة',
            minBid: 'الحد الأدنى للمزايدة',
            minBidInfo: 'الحد الأدنى للمزايدة: $0.00',
            autoBidInfo: 'ستزايد تلقائياً حتى هذا المبلغ',
            endingSoon: 'ينتهي قريباً',
            ended: 'انتهى',
            active: 'نشط',
            cancelled: 'ملغي',
            winner: 'الفائز',
            winning: 'فائز',
            outbid: 'تم تجاوز مزايدتك',
            noBids: 'لا توجد مزايدات بعد',
            filterBy: 'تصفية حسب',
            sortBy: 'ترتيب حسب',
            category: 'الفئة',
            allCategories: 'جميع الفئات',
            price: 'السعر',
            priceHighToLow: 'السعر (من الأعلى إلى الأدنى)',
            priceLowToHigh: 'السعر (من الأدنى إلى الأعلى)',
            minPrice: 'الحد الأدنى للسعر',
            maxPrice: 'الحد الأقصى للسعر',
            timeLeftSort: 'الوقت المتبقي',
            mostBids: 'أكثر المزايدات',
            bidCount: 'عدد المزايدات',
            totalBids: 'إجمالي المزايدات',
            gridView: 'عرض الشبكة',
            listView: 'عرض القائمة',
            applyFilters: 'تطبيق الفلاتر',
            reset: 'إعادة تعيين',
            searchAuctions: 'بحث في المزادات...',
            loadingAuctions: 'جاري تحميل المزادات...',
            loadingDetails: 'جاري تحميل تفاصيل المزاد...',
            description: 'الوصف',
            bidIncrement: 'زيادة المزايدة',
            auctionEnded: 'انتهى هذا المزاد.',
            winnerInfo: 'معلومات الفائز',
            seller: 'البائع',
            sellerName: 'اسم البائع',
            sellerEmail: 'بريد البائع الإلكتروني',
            selectCategory: 'اختر الفئة',
            featureHomepage: 'اعرض هذا المزاد على الصفحة الرئيسية',
            viewDetails: 'عرض التفاصيل',
            shareAuction: 'مشاركة المزاد',
            watchAuction: 'متابعة المزاد',
            unwatchAuction: 'إلغاء المتابعة',
            reportAuction: 'الإبلاغ عن المزاد'
        },
        // Create Auction
        createAuction: {
            title: 'إنشاء مزاد',
            createNewAuction: 'إنشاء مزاد جديد',
            itemName: 'اسم السلعة',
            description: 'الوصف',
            startingBid: 'السعر الابتدائي',
            startingBidLabel: 'السعر الابتدائي ($)',
            bidIncrement: 'زيادة المزايدة',
            bidIncrementLabel: 'زيادة المزايدة ($)',
            endTime: 'وقت الانتهاء',
            endDateAndTime: 'تاريخ ووقت الانتهاء',
            category: 'الفئة',
            selectCategory: 'اختر الفئة',
            images: 'الصور',
            imageUrls: 'روابط الصور (واحد لكل سطر)',
            imageUrlsPlaceholder: 'أدخل روابط الصور، واحد لكل سطر\nhttps://example.com/image1.jpg\nhttps://example.com/image2.jpg',
            imageUrlsHint: 'يمكنك إضافة روابط الصور أو رفع صور من جهازك.',
            addImage: 'إضافة صورة',
            featured: 'مزاد مميز',
            featureHomepage: 'اعرض هذا المزاد على الصفحة الرئيسية',
            create: 'إنشاء مزاد',
            creating: 'جاري الإنشاء...',
            success: 'تم إنشاء المزاد بنجاح!',
            failed: 'فشل إنشاء المزاد',
            uploadImages: 'رفع الصور',
            dragDropImages: 'اسحب وأفلت الصور هنا',
            maxImages: 'الحد الأقصى 10 صور'
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
            phone: 'رقم الجوال',
            role: 'الدور',
            editProfile: 'تعديل الملف الشخصي',
            updateProfile: 'تحديث الملف الشخصي',
            saveChanges: 'حفظ التغييرات',
            updating: 'جاري التحديث...',
            updateSuccess: 'تم تحديث الملف الشخصي بنجاح!',
            updateFailed: 'فشل تحديث الملف الشخصي',
            myAuctions: 'مزاداتي',
            myBids: 'مزاداتي',
            totalAuctions: 'إجمالي المزادات',
            totalBids: 'إجمالي المزايدات',
            loadingProfile: 'جاري تحميل الملف الشخصي...',
            usernameCannotChange: 'لا يمكن تغيير اسم المستخدم',
            phoneHint: 'سنستخدم هذا للاتصال بك بشأن مزاداتك',
            addressHint: 'مطلوب لمعاملات المزاد والشحن',
            changePassword: 'تغيير كلمة المرور',
            currentPassword: 'كلمة المرور الحالية',
            newPassword: 'كلمة المرور الجديدة',
            confirmNewPassword: 'تأكيد كلمة المرور الجديدة',
            passwordChanged: 'تم تغيير كلمة المرور بنجاح',
            accountSettings: 'إعدادات الحساب',
            notifications: 'الإشعارات',
            privacy: 'الخصوصية'
        },
        // Payments
        payments: {
            title: 'المدفوعات',
            invoice: 'الفاتورة',
            itemPrice: 'سعر السلعة',
            bidFee: 'رسوم المزايدة',
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
            paymentFailed: 'فشل الدفع',
            paymentHistory: 'سجل المدفوعات',
            transactionId: 'رقم المعاملة',
            refund: 'استرداد',
            refundRequested: 'تم طلب الاسترداد',
            refundProcessed: 'تم معالجة الاسترداد',
            noPayments: 'لا توجد مدفوعات',
            viewInvoice: 'عرض الفاتورة',
            downloadInvoice: 'تحميل الفاتورة'
        },
        // How to Bid page
        howToBidPage: {
            pageTitle: 'كيفية استخدام زوبيد',
            intro: 'تعلم كيفية استخدام زوبيد - دليلك الشامل للمزايدة والبيع وإدارة حسابك على منصتنا المميزة للمزادات.',
            // Getting Started Section
            gettingStartedTitle: 'البدء',
            step1Title: 'إنشاء حسابك',
            step1Text: 'ابدأ بإنشاء حساب مجاني على زوبيد. انقر على زر "إنشاء حساب" في شريط التنقل واملأ بياناتك. ستحتاج إلى:',
            step1Item1: 'اسم المستخدم والبريد الإلكتروني',
            step1Item2: 'كلمة مرور قوية (8+ أحرف مع أرقام وحروف)',
            step1Item3: 'صورة الملف الشخصي (اختيارية لكن موصى بها)',
            step1Cta: 'إنشاء حساب الآن',
            step2Title: 'تصفح المزادات',
            step2Text: 'استكشف مجموعتنا الواسعة من المزادات. يمكنك:',
            step2Item1: 'التصفح حسب الفئة (إلكترونيات، مجوهرات، سيارات، فن، أزياء)',
            step2Item2: 'البحث عن سلع محددة باستخدام شريط البحث',
            step2Item3: 'التصفية حسب نطاق السعر، الحالة، والوقت المتبقي',
            step2Item4: 'عرض المزادات المميزة في الصفحة الرئيسية',
            step2Item5: 'التبديل بين عرض الشبكة والقائمة',
            step2Cta: 'تصفح المزادات',
            step3Title: 'عرض تفاصيل المزاد',
            step3Text: 'انقر على أي مزاد لعرض التفاصيل الكاملة:',
            step3Item1: 'صور عالية الجودة مع إمكانية التكبير',
            step3Item2: 'السعر الحالي والحد الأدنى للزيادة',
            step3Item3: 'عداد تنازلي مباشر يعرض الوقت المتبقي',
            step3Item4: 'سجل المزايدات الكامل ومعلومات المزايدين',
            step3Item5: 'معلومات البائع وتقييماته',
            step3Item6: 'مشاركة المزاد عبر وسائل التواصل أو نسخ الرابط',
            // Bidding Section
            biddingTitle: 'كيفية المزايدة',
            step4Title: 'قدّم مزايدتك',
            step4Text: 'عندما تكون جاهزاً للمزايدة:',
            step4Item1: 'أدخل مبلغ المزايدة (يجب استيفاء الحد الأدنى)',
            step4Item2: 'فعّل المزايدة التلقائية للمنافسة تلقائياً حتى حدك الأقصى',
            step4Item3: 'انقر على "قدم مزايدة" للإرسال',
            step4Item4: 'راقب التحديثات الفورية أثناء مزايدات الآخرين',
            step4Item5: 'احصل على إشعارات فورية عند تجاوز مزايدتك',
            step4Tip: 'نصيحة احترافية: استخدم المزايدة التلقائية لزيادة مزايدتك تلقائياً حتى الحد الأقصى عندما يتفوق الآخرون عليك. بهذه الطريقة لن تفوتك الفرص حتى عندما تكون بعيداً!',
            step5Title: 'الفوز والدفع',
            step5Text: 'إذا فزت بالمزاد:',
            step5Item1: 'ستتلقى إشعاراً فورياً عند انتهاء المزاد',
            step5Item2: 'سيتم إنشاء فاتورة تلقائياً',
            step5Item3: 'أكمل الدفع عبر طرق آمنة',
            step5Item4: 'تابع طلبك ونسّق التوصيل',
            step5Item5: 'اترك تقييماً بعد استلام السلعة',
            // Selling Section
            sellingTitle: 'كيفية البيع',
            sellStep1Title: 'إنشاء مزاد',
            sellStep1Text: 'قم بإدراج سلعك للمزاد:',
            sellStep1Item1: 'اذهب إلى "حسابي" > "إنشاء مزاد"',
            sellStep1Item2: 'ارفع صوراً عالية الجودة لسلعتك',
            sellStep1Item3: 'اكتب وصفاً تفصيلياً',
            sellStep1Item4: 'حدد سعر البداية ومدة المزاد',
            sellStep1Item5: 'اختر الفئة المناسبة',
            sellStep2Title: 'إدارة مزاداتك',
            sellStep2Text: 'تابع إعلاناتك:',
            sellStep2Item1: 'اعرض جميع مزاداتك في "مزاداتي"',
            sellStep2Item2: 'راقب المزايدات ونشاط المزايدين',
            sellStep2Item3: 'عدّل تفاصيل المزاد إذا لزم الأمر',
            sellStep2Item4: 'أجب على أسئلة المشترين',
            sellStep3Title: 'إتمام البيع',
            sellStep3Text: 'بعد انتهاء مزادك:',
            sellStep3Item1: 'تواصل مع الفائز بالمزاد',
            sellStep3Item2: 'نسّق استلام الدفعة',
            sellStep3Item3: 'شحن السلعة أو ترتيب الاستلام',
            sellStep3Item4: 'ضع علامة "تم التسليم" عند الانتهاء',
            // Account Management Section
            accountTitle: 'إدارة حسابك',
            profileTitle: 'ملفك الشخصي',
            profileText: 'خصّص ملفك الشخصي وأدر الإعدادات:',
            profileItem1: 'حدّث صورة الملف الشخصي والمعلومات الشخصية',
            profileItem2: 'غيّر كلمة المرور بشكل آمن',
            profileItem3: 'اعرض سجل مزايداتك',
            profileItem4: 'تابع المزادات التي فزت بها ومشترياتك',
            profileItem5: 'أدر تفضيلات الإشعارات',
            myBidsTitle: 'مزايداتي',
            myBidsText: 'تابع جميع نشاط مزايداتك:',
            myBidsItem1: 'اعرض المزايدات النشطة على المزادات الجارية',
            myBidsItem2: 'شاهد المزادات التي فزت بها',
            myBidsItem3: 'تحقق من إشعارات تجاوز المزايدة',
            myBidsItem4: 'ألغِ المزايدات التلقائية إذا لزم الأمر',
            paymentsTitle: 'المدفوعات',
            paymentsText: 'أدر معاملاتك المالية:',
            paymentsItem1: 'اعرض المدفوعات المعلقة والمكتملة',
            paymentsItem2: 'حمّل الفواتير والإيصالات',
            paymentsItem3: 'تابع سجل المدفوعات',
            paymentsItem4: 'اطلب الإرجاع إذا لزم الأمر',
            // App Features Section
            featuresTitle: 'ميزات التطبيق',
            languageTitle: 'اختيار اللغة',
            languageText: 'يدعم زوبيد عدة لغات:',
            languageItem1: 'انقر على أيقونة الكرة الأرضية (🌐) في شريط التنقل',
            languageItem2: 'اختر من الإنجليزية أو الكردية (کوردی) أو العربية',
            languageItem3: 'سيتحول التطبيق بالكامل إلى اللغة المختارة',
            languageItem4: 'يتم حفظ تفضيلك تلقائياً',
            themeTitle: 'الوضع الداكن/الفاتح',
            themeText: 'التبديل بين المظاهر المرئية:',
            themeItem1: 'انقر على أيقونة الشمس/القمر في شريط التنقل',
            themeItem2: 'الوضع الداكن أسهل على العينين في الليل',
            themeItem3: 'يتم حفظ تفضيل المظهر تلقائياً',
            notificationsTitle: 'الإشعارات',
            notificationsText: 'ابقَ على اطلاع بنشاط المزاد:',
            notificationsItem1: 'احصل على إشعار عند تجاوز مزايدتك',
            notificationsItem2: 'تلقَّ تنبيهات عندما تقترب المزادات التي تتابعها من الانتهاء',
            notificationsItem3: 'احصل على إشعار فوري عند الفوز',
            notificationsItem4: 'انقر على أيقونة الجرس لعرض جميع الإشعارات',
            // Tips Section
            tipsTitle: 'نصائح للمزايدة',
            tipsItem1: 'حدد ميزانية قصوى قبل البدء بالمزايدة',
            tipsItem2: 'استخدم المزايدة التلقائية للبقاء في المنافسة تلقائياً',
            tipsItem3: 'اقرأ وصف السلع واعرض جميع الصور بعناية',
            tipsItem4: 'تحقق من تقييمات البائع والمعاملات السابقة',
            tipsItem5: 'راقب العداد التنازلي - المزايدة في اللحظة الأخيرة مكثفة!',
            tipsItem6: 'قدّم مزايداتك مبكراً لإظهار الاهتمام الجاد',
            tipsItem7: 'فعّل الإشعارات لتبقى على اطلاع دائم',
            // FAQ Section
            faqTitle: 'الأسئلة الشائعة',
            faqQ1: 'هل يمكنني إلغاء أو سحب مزايدة؟',
            faqA1: 'المزايدات ملزمة ولا يمكن سحبها. يرجى المزايدة بحذر وتقديم مزايدات أنت ملتزم بالوفاء بها.',
            faqQ2: 'ماذا يحدث إذا تم تجاوز مزايدتي؟',
            faqA2: 'ستتلقى إشعاراً فورياً. إذا كانت المزايدة التلقائية مفعلة، ستقوم تلقائياً بتقديم مزايدة أعلى حتى حدك الأقصى.',
            faqQ3: 'كيف تعمل المزايدة التلقائية؟',
            faqA3: 'المزايدة التلقائية تزيد مزايدتك تلقائياً بالحد الأدنى للزيادة عندما يتفوق الآخرون عليك، حتى تصل إلى المبلغ الأقصى الذي حددته. إنها كمساعد للمزايدة!',
            faqQ4: 'ما هي الرسوم؟',
            faqA4: 'يدفع المشترون رسوم خدمة صغيرة بنسبة 1% على المزايدات الفائزة. قد يكون للبائعين رسوم إدراج حسب نوع الحساب.',
            faqQ5: 'كيف أتواصل مع البائع؟',
            faqA5: 'يمكنك عرض معلومات البائع في صفحة المزاد. بعد الفوز، ستتلقى تفاصيل الاتصال بالبائع.',
            faqQ6: 'ماذا لو لم أستلم سلعتي؟',
            faqA6: 'استخدم ميزة طلب الإرجاع في حسابك. سيساعدك فريق الدعم في حل أي مشكلات.',
            faqQ7: 'كيف أغيّر اللغة؟',
            faqA7: 'انقر على أيقونة الكرة الأرضية (🌐) في شريط التنقل العلوي واختر لغتك المفضلة.',
            faqQ8: 'هل معلومات الدفع الخاصة بي آمنة؟',
            faqA8: 'نعم، جميع المعاملات مؤمنة بتشفير معياري صناعي. لا نخزن أبداً تفاصيل الدفع الكاملة الخاصة بك.',
            // CTA Section
            ctaTitle: 'جاهز للبدء؟',
            ctaText: 'انضم إلى آلاف المشترين والبائعين على زوبيد اليوم!',
            ctaPrimary: 'إنشاء حساب',
            ctaSecondary: 'تصفح المزادات'
        },
        // Contact Us page
        contactPage: {
            intro: 'تواصل معنا. نحن هنا لمساعدتك في أي أسئلة أو استفسارات.',
            getInTouchTitle: 'تواصل معنا',
            emailTitle: 'البريد الإلكتروني',
            phoneTitle: 'الهاتف',
            phoneHoursShort: 'السبت - الخميس: 9:00 ص - 6:00 م',
            addressTitle: 'العنوان',
            addressLine1: 'شارع 60 متري، مجمع ماس مول',
            addressLine2: 'أربيل، إقليم كردستان',
            addressLine3: 'العراق',
            businessHoursTitle: 'ساعات العمل',
            hoursWeekdays: 'السبت - الخميس: 9:00 ص - 6:00 م',
            hoursSaturday: 'الجمعة: 10:00 ص - 2:00 م',
            hoursSunday: 'العطل الرسمية: مغلق',
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
            submitButton: 'إرسال الرسالة',
            messageSent: 'تم إرسال رسالتك بنجاح!',
            messageFailed: 'فشل إرسال الرسالة. يرجى المحاولة مرة أخرى.',
            responseTime: 'سنرد عليك خلال 24 ساعة'
        },
        // My Bids page
        myBidsPage: {
            title: 'مزاداتي الرابحة',
            subtitle: 'يعرض فقط المزادات التي فزت بها أو التي تتصدرها حالياً',
            loading: 'جاري تحميل مزاداتك...',
            noWinningTitle: 'ليس لديك أي مزايدات رابحة بعد.',
            noWinningSubtitle: 'استمر في المزايدة للفوز بالمزادات المميزة!',
            noBidsTitle: 'لم تقم بتقديم أي مزايدات بعد.',
            browseAuctions: 'تصفح المزادات',
            loadError: 'تعذر تحميل مزاداتك. يرجى المحاولة مرة أخرى.',
            loadErrorShort: 'تعذر تحميل مزاداتك',
            loginRequired: 'يرجى تسجيل الدخول لعرض مزاداتك',
            unknownAuction: 'مزاد غير معروف',
            unknownTime: 'وقت غير معروف',
            currentLabel: 'السعر الحالي:',
            auctionEndedBadge: 'انتهى المزاد',
            statusWon: 'فائز',
            statusWinning: 'متصدر',
            statusOutbid: 'تمت المزايدة عليك',
            autoBidBadge: 'مزايدة تلقائية'
        },
        // Admin
        admin: {
            title: 'لوحة تحكم المدير',
            dashboard: 'لوحة التحكم',
            users: 'المستخدمون',
            auctions: 'المزادات',
            categories: 'الفئات',
            stats: 'الإحصائيات',
            totalUsers: 'إجمالي المستخدمين',
            totalAdmins: 'إجمالي المديرين',
            totalAuctions: 'إجمالي المزادات',
            activeAuctions: 'المزادات النشطة',
            endedAuctions: 'المزادات المنتهية',
            totalBids: 'إجمالي المزايدات',
            recentUsers: 'المستخدمون الجدد',
            manageUsers: 'إدارة المستخدمين',
            manageAuctions: 'إدارة المزادات',
            manageCategories: 'إدارة الفئات',
            createAuction: 'إنشاء مزاد',
            editAuction: 'تعديل المزاد',
            deleteAuction: 'حذف المزاد',
            approveAuction: 'الموافقة على المزاد',
            rejectAuction: 'رفض المزاد',
            userDetails: 'تفاصيل المستخدم',
            makeAdmin: 'جعله مديراً',
            removeAdmin: 'إزالة صلاحيات المدير',
            banUser: 'حظر المستخدم',
            unbanUser: 'إلغاء حظر المستخدم',
            reports: 'التقارير',
            settings: 'الإعدادات',
            systemSettings: 'إعدادات النظام',
            siteSettings: 'إعدادات الموقع',
            pendingApproval: 'بانتظار الموافقة',
            approved: 'موافق عليه',
            rejected: 'مرفوض'
        },
        // Messages
        messages: {
            serverError: 'لا يمكن الاتصال بالخادم! تأكد من أن الخادم يعمل على المنفذ 5000.',
            unauthorized: 'غير مصرح لك بتنفيذ هذا الإجراء',
            notFound: 'المورد غير موجود',
            validationError: 'يرجى التحقق من البيانات والمحاولة مرة أخرى',
            networkError: 'خطأ في الشبكة. يرجى التحقق من اتصالك.',
            genericError: 'حدث خطأ. يرجى المحاولة مرة أخرى لاحقاً.',
            invalidAuctionId: 'معرّف المزاد غير صحيح',
            loginRequired: 'يرجى تسجيل الدخول للمزايدة',
            auctionInactive: 'لم يعد هذا المزاد نشطاً',
            invalidVideoUrl: 'تنسيق رابط الفيديو غير صحيح',
            noFeaturedAuctions: 'لا توجد مزادات مميزة متاحة',
            linkCopied: 'تم نسخ الرابط!',
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
            passwordRequirementSpecial: 'رمز خاص واحد (!@#$%^&*)',
            passwordMustMeetRequirements: 'يجب أن تستوفي كلمة المرور جميع المتطلبات',
            admin: 'المدير',
            howToBid: 'كيفية المزايدة',
            contactUs: 'اتصل بنا',
            returnRequests: 'طلبات الإرجاع',
            info: 'معلومات',
            profilePhoto: 'صورة الملف الشخصي',
            uploadPhoto: 'رفع صورة',
            optional: 'اختياري',
            max5MB: 'حد أقصى 5MB، JPG/PNG',
            confirmDelete: 'هل أنت متأكد من الحذف؟',
            deleteSuccess: 'تم الحذف بنجاح',
            deleteFailed: 'فشل الحذف',
            updateSuccess: 'تم التحديث بنجاح',
            updateFailed: 'فشل التحديث',
            createSuccess: 'تم الإنشاء بنجاح',
            createFailed: 'فشل الإنشاء',
            welcome: 'مرحباً',
            goodbye: 'مع السلامة',
            thankYou: 'شكراً لك'
        },
        // Return Requests
        returnRequests: {
            title: 'طلبات الإرجاع',
            requestReturn: 'طلب إرجاع',
            reason: 'السبب',
            description: 'الوصف',
            status: 'الحالة',
            pending: 'قيد الانتظار',
            approved: 'موافق عليه',
            rejected: 'مرفوض',
            noRequests: 'لا توجد طلبات إرجاع',
            submitRequest: 'إرسال الطلب',
            selectReason: 'اختر سبباً',
            reasonDamaged: 'السلعة تالفة',
            reasonWrongItem: 'تم إرسال سلعة خاطئة',
            reasonNotAsDescribed: 'ليست كما في الوصف',
            reasonOther: 'سبب آخر'
        },
        // My Auctions
        myAuctions: {
            title: 'مزاداتي',
            active: 'نشط',
            ended: 'منتهي',
            pending: 'قيد الانتظار',
            noAuctions: 'ليس لديك مزادات',
            createFirst: 'أنشئ مزادك الأول',
            totalEarnings: 'إجمالي الأرباح',
            totalSold: 'إجمالي المبيعات'
        },
        // Footer
        footer: {
            aboutUs: 'من نحن',
            termsOfService: 'شروط الخدمة',
            privacyPolicy: 'سياسة الخصوصية',
            helpCenter: 'مركز المساعدة',
            followUs: 'تابعنا',
            copyright: '© 2025 زوبيد. جميع الحقوق محفوظة.',
            quickLinks: 'روابط سريعة',
            support: 'الدعم',
            legal: 'قانوني'
        },
        // Categories
        categories: {
            electronics: 'إلكترونيات',
            vehicles: 'سيارات',
            jewelry: 'مجوهرات',
            fashion: 'أزياء',
            art: 'فن',
            collectibles: 'مقتنيات',
            realEstate: 'عقارات',
            sports: 'رياضة',
            other: 'أخرى'
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

