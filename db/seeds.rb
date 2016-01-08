10.times do
	user = User.create(
		email: FFaker::Internet.email,
		password: FFaker::Lorem.words(5).join
	)
	5.times do
		user.posts.create(
			title: FFaker::Lorem.words(5).join(" ").titleize,
			content: FFaker::Lorem.paragraphs(3).join(" ")
		)
	end
end

posts_count = Post.count
post_ids = (1..posts_count).to_a

User.all.each do |user|
	5.times do
		user.comments.create(
			content: FFaker::Lorem.paragraph,
			post_id: post_ids.sample
		)
	end
end