"""init

Revision ID: 47f500f1c1f2
Revises: 
Create Date: 2022-08-26 16:08:50.071037

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '47f500f1c1f2'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('user',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('email', sa.String(length=120), nullable=True),
    sa.Column('username', sa.String(length=64), nullable=True),
    sa.Column('fullname', sa.String(length=100), nullable=True),
    sa.Column('image', sa.String(length=300), nullable=True),
    sa.Column('login_counts', sa.Integer(), nullable=True),
    sa.Column('password_hash', sa.String(length=300), nullable=True),
    sa.Column('is_active', sa.Boolean(), nullable=True),
    sa.Column('activation_token', sa.String(length=42), nullable=True),
    sa.Column('activation_date', sa.DateTime(), nullable=True),
    sa.Column('token', sa.String(length=42), nullable=True),
    sa.Column('token_date', sa.DateTime(), nullable=True),
    sa.Column('forgotten_password_token', sa.String(length=300), nullable=True),
    sa.Column('forgotten_password_date', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_user_email'), 'user', ['email'], unique=True)
    op.create_index(op.f('ix_user_username'), 'user', ['username'], unique=False)
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_index(op.f('ix_user_username'), table_name='user')
    op.drop_index(op.f('ix_user_email'), table_name='user')
    op.drop_table('user')
    # ### end Alembic commands ###