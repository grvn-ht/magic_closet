from datetime import datetime, timedelta
import os

def create_sample_data(db, User, Closet, Info,app):
    with app.app_context():  # Activate the application context
        user = User(email='aa', password='aa')
        db.session.add(user)
        db.session.commit()

        closet = Closet(user_id=user.id)
        db.session.add(closet)
        db.session.commit()

        start_date = datetime(2023, 8, 29)
        time_interval = timedelta(minutes=30)

        for i in range(50):
            temp = -5 + (i * 1.1)
            hum = i * 2
            ph = i * 0.3
            ec = 0.3 + (i * 0.03)
            with open('sample_image.jpg', 'rb') as image_file:
                image_data = image_file.read()

            event_date = start_date + (i * time_interval)
            created_at = event_date

            info = Info(temp=temp, hum=hum, ph=ph, ec=ec, image=image_data,
                        event_date=event_date.date(), created_at=created_at, closet_id=closet.id)

            db.session.add(info)

        db.session.commit()
