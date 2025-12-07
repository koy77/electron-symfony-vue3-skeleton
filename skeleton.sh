#!/bin/bash

set -e

echo "🚀 Creating Symfony API Platform project..."

# Check if backend directory exists
if [ ! -d "backend" ]; then
    echo "❌ Backend directory not found. Please run from project root."
    exit 1
fi

cd backend

# Install Symfony CLI if not present
if ! command -v symfony &> /dev/null; then
    echo "📦 Installing Symfony CLI..."
    curl -sS https://get.symfony.com/cli | bash
    export PATH="$HOME/.symfony5/bin:$PATH"
fi

# Create new Symfony API Platform project
echo "🔧 Creating Symfony API Platform project..."
symfony new --webapp --version=lts . --no-git

# Install API Platform
echo "📚 Installing API Platform..."
composer require api

# Install additional useful packages
echo "🔧 Installing additional packages..."
composer require \
    doctrine/orm \
    doctrine/doctrine-bundle \
    doctrine/doctrine-migrations-bundle \
    symfony/validator \
    symfony/serializer \
    symfony/security-bundle \
    lexik/jwt-authentication-bundle \
    nelmio/cors-bundle \
    api-platform/core

# Install development dependencies
echo "🛠️ Installing development dependencies..."
composer require --dev \
    symfony/maker-bundle \
    symfony/profiler-pack \
    doctrine/doctrine-fixtures-bundle \
    phpunit/phpunit \
    symfony/test-pack

# Create basic directory structure
echo "📁 Creating directory structure..."
mkdir -p src/Entity src/Repository src/Controller src/Service src/EventSubscriber
mkdir -p config/packages/dev config/packages/prod config/packages/test
mkdir -p tests/Unit tests/Functional

# Create basic .env.local template
echo "⚙️ Creating environment configuration..."
cat > .env.local << 'EOF'
# Database configuration
DATABASE_URL="postgresql://app:!ChangeMe!@127.0.0.1:5432/app?serverVersion=16&charset=utf8"

# JWT Configuration
JWT_SECRET_KEY="%kernel.project_dir%/config/jwt/private.pem"
JWT_PUBLIC_KEY="%kernel.project_dir%/config/jwt/public.pem"
JWT_PASSPHRASE="your-secret-passphrase"

# CORS Configuration
CORS_ALLOW_ORIGIN="^http://localhost:5173$"

# App secrets
APP_SECRET="changeme_generate_a_real_secret_key_here"
EOF

# Generate JWT keys
echo "🔐 Generating JWT keys..."
mkdir -p config/jwt
openssl genpkey -out config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096
openssl pkey -in config/jwt/private.pem -out config/jwt/public.pem -pubout

# Create basic API Platform configuration
echo "⚙️ Configuring API Platform..."
cat > config/packages/api_platform.yaml << 'EOF'
api_platform:
    title: 'Coding UI API'
    description: 'A modern API built with Symfony and API Platform'
    version: '1.0.0'
    mapping:
        paths: ['%kernel.project_dir%/src/Entity']
    formats:
        jsonld: ['application/ld+json']
        json: ['application/json']
        html: ['text/html']
    docs_formats:
        jsonld: ['application/ld+json']
        json: ['application/json']
        html: ['text/html']
    swagger:
        versions: [3]
        api_keys:
            - name: 'Authorization'
              type: 'header'
EOF

# Create CORS configuration
echo "🌐 Configuring CORS..."
cat > config/packages/nelmio_cors.yaml << 'EOF'
nelmio_cors:
    defaults:
        origin_regex: true
        allow_origin: ['%env(CORS_ALLOW_ORIGIN)%']
        allow_methods: ['GET', 'OPTIONS', 'POST', 'PUT', 'PATCH', 'DELETE']
        allow_headers: ['Content-Type', 'Authorization']
        expose_headers: ['Link']
        max_age: 3600
    paths:
        '^/api/': ~
EOF

# Create basic security configuration
echo "🔒 Configuring security..."
cat > config/packages/security.yaml << 'EOF'
security:
    password_hashers:
        Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface: 'auto'

    providers:
        app_user_provider:
            entity:
                class: App\Entity\User
                property: email

    firewalls:
        login:
            pattern: ^/api/login
            stateless: true
            json_login:
                check_path: /api/login_check
                success_handler: lexik_jwt_authentication.handler.authentication_success
                failure_handler: lexik_jwt_authentication.handler.authentication_failure

        api:
            pattern: ^/api
            stateless: true
            jwt: ~

        dev:
            pattern: ^/(_(profiler|wdt)|css|images|js)/
            security: false

        main:
            lazy: true
            provider: app_user_provider

    access_control:
        - { path: ^/api/login, roles: PUBLIC_ACCESS }
        - { path: ^/api/docs, roles: PUBLIC_ACCESS }
        - { path: ^/api, roles: IS_AUTHENTICATED_FULLY }
EOF

# Create a basic User entity
echo "👤 Creating User entity..."
cat > src/Entity/User.php << 'EOF'
<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Post;
use App\Repository\UserRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ApiResource(
    operations: [
        new GetCollection(security: 'is_granted("ROLE_ADMIN")'),
        new Post(security: 'is_granted("PUBLIC_ACCESS")'),
        new Get(security: 'is_granted("ROLE_USER") or object == user'),
    ],
    normalizationContext: ['groups' => ['user:read']],
    denormalizationContext: ['groups' => ['user:write']]
)]
class User implements UserInterface, PasswordAuthenticatedUserInterface
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['user:read'])]
    private ?int $id = null;

    #[ORM\Column(length: 180, unique: true)]
    #[Groups(['user:read', 'user:write'])]
    private ?string $email = null;

    #[ORM\Column]
    private array $roles = [];

    /**
     * @var string The hashed password
     */
    #[ORM\Column]
    #[Groups(['user:write'])]
    private ?string $password = null;

    #[ORM\Column(type: 'datetime_immutable')]
    #[Groups(['user:read'])]
    private ?\DateTimeImmutable $createdAt = null;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function setEmail(string $email): self
    {
        $this->email = $email;

        return $this;
    }

    /**
     * A visual identifier that represents this user.
     *
     * @see UserInterface
     */
    public function getUserIdentifier(): string
    {
        return (string) $this->email;
    }

    /**
     * @see UserInterface
     */
    public function getRoles(): array
    {
        $roles = $this->roles;
        // guarantee every user at least has ROLE_USER
        $roles[] = 'ROLE_USER';

        return array_unique($roles);
    }

    public function setRoles(array $roles): self
    {
        $this->roles = $roles;

        return $this;
    }

    /**
     * @see PasswordAuthenticatedUserInterface
     */
    public function getPassword(): string
    {
        return $this->password;
    }

    public function setPassword(string $password): self
    {
        $this->password = $password;

        return $this;
    }

    /**
     * @see UserInterface
     */
    public function eraseCredentials(): void
    {
        // If you store any temporary, sensitive data on the user, clear it here
        // $this->plainPassword = null;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }
}
EOF

# Create User repository
echo "📚 Creating User repository..."
cat > src/Repository/UserRepository.php << 'EOF'
<?php

namespace App\Repository;

use App\Entity\User;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<User>
 */
class UserRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, User::class);
    }

    public function save(User $entity, bool $flush = false): void
    {
        $this->getEntityManager()->persist($entity);

        if ($flush) {
            $this->getEntityManager()->flush();
        }
    }

    public function remove(User $entity, bool $flush = false): void
    {
        $this->getEntityManager()->remove($entity);

        if ($flush) {
            $this->getEntityManager()->flush();
        }
    }

    public function findByEmail(string $email): ?User
    {
        return $this->findOneBy(['email' => $email]);
    }
}
EOF

# Create a basic example entity
echo "📝 Creating example Task entity..."
cat > src/Entity/Task.php << 'EOF'
<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use App\Repository\TaskRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: TaskRepository::class)]
#[ApiResource(
    normalizationContext: ['groups' => ['task:read']],
    denormalizationContext: ['groups' => ['task:write']]
)]
class Task
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['task:read'])]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    #[Groups(['task:read', 'task:write'])]
    private ?string $title = null;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['task:read', 'task:write'])]
    private ?string $description = null;

    #[ORM\Column]
    #[Groups(['task:read', 'task:write'])]
    private ?bool $completed = false;

    #[ORM\Column(type: 'datetime_immutable')]
    #[Groups(['task:read'])]
    private ?\DateTimeImmutable $createdAt = null;

    #[ORM\ManyToOne(inversedBy: 'tasks')]
    #[ORM\JoinColumn(nullable: false)]
    #[Groups(['task:read', 'task:write'])]
    private ?User $owner = null;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getTitle(): ?string
    {
        return $this->title;
    }

    public function setTitle(string $title): self
    {
        $this->title = $title;

        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): self
    {
        $this->description = $description;

        return $this;
    }

    public function isCompleted(): ?bool
    {
        return $this->completed;
    }

    public function setCompleted(bool $completed): self
    {
        $this->completed = $completed;

        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function getOwner(): ?User
    {
        return $this->owner;
    }

    public function setOwner(?User $owner): self
    {
        $this->owner = $owner;

        return $this;
    }
}
EOF

# Create Task repository
cat > src/Repository/TaskRepository.php << 'EOF'
<?php

namespace App\Repository;

use App\Entity\Task;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Task>
 */
class TaskRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Task::class);
    }

    public function save(Task $entity, bool $flush = false): void
    {
        $this->getEntityManager()->persist($entity);

        if ($flush) {
            $this->getEntityManager()->flush();
        }
    }

    public function remove(Task $entity, bool $flush = false): void
    {
        $this->getEntityManager()->remove($entity);

        if ($flush) {
            $this->getEntityManager()->flush();
        }
    }

    public function findByOwner(User $owner): array
    {
        return $this->findBy(['owner' => $owner], ['createdAt' => 'DESC']);
    }
}
EOF

# Update User entity to include tasks relationship
echo "🔗 Updating User entity with tasks relationship..."
sed -i '/use Symfony\\Component\\Serializer\\Annotation\\Groups;/a\\nuse Doctrine\\Common\\Collections\\ArrayCollection;\\nuse Doctrine\\Common\\Collections\\Collection;' src/Entity/User.php

sed -i '/private \\?\\DateTimeImmutable \\$createdAt = null;/i\\n    \/**\n     * @var Collection<int, Task>\n     *\/\n    #[ORM\\OneToMany(mappedBy: \"owner\", targetEntity: Task::class)]\n    #[Groups([\"user:read\"])]\n    private Collection $tasks;\n\n' src/Entity/User.php

sed -i '/public function __construct()/i\\n    public function __construct()\n    {\n        $this->tasks = new ArrayCollection();\n        $this->createdAt = new \\DateTimeImmutable();\n    }' src/Entity/User.php

# Add task methods to User entity
cat >> src/Entity/User.php << 'EOF'

    /**
     * @return Collection<int, Task>
     */
    public function getTasks(): Collection
    {
        return $this->tasks;
    }

    public function addTask(Task $task): self
    {
        if (!$this->tasks->contains($task)) {
            $this->tasks->add($task);
            $task->setOwner($this);
        }

        return $this;
    }

    public function removeTask(Task $task): self
    {
        if ($this->tasks->removeElement($task)) {
            // set the owning side to null (unless already changed)
            if ($task->getOwner() === $this) {
                $task->setOwner(null);
            }
        }

        return $this;
    }
EOF

# Create database schema
echo "🗄️ Creating database schema..."
php bin/console doctrine:database:create --if-not-exists
php bin/console doctrine:schema:create

# Create fixtures
echo "🎲 Creating fixtures..."
cat > src/DataFixtures/AppFixtures.php << 'EOF'
<?php

namespace App\DataFixtures;

use App\Entity\Task;
use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class AppFixtures extends Fixture
{
    public function __construct(private UserPasswordHasherInterface $passwordHasher)
    {
    }

    public function load(ObjectManager $manager): void
    {
        // Create admin user
        $admin = new User();
        $admin->setEmail('admin@example.com');
        $admin->setRoles(['ROLE_ADMIN']);
        $admin->setPassword($this->passwordHasher->hashPassword($admin, 'admin123'));
        $manager->persist($admin);

        // Create regular user
        $user = new User();
        $user->setEmail('user@example.com');
        $user->setRoles(['ROLE_USER']);
        $user->setPassword($this->passwordHasher->hashPassword($user, 'user123'));
        $manager->persist($user);

        // Create sample tasks
        for ($i = 1; $i <= 5; $i++) {
            $task = new Task();
            $task->setTitle("Task $i");
            $task->setDescription("Description for task $i");
            $task->setCompleted($i % 2 === 0);
            $task->setOwner($i % 2 === 0 ? $admin : $user);
            $manager->persist($task);
        }

        $manager->flush();
    }
}
EOF

# Load fixtures
echo "📊 Loading fixtures..."
php bin/console doctrine:fixtures:load --no-interaction

# Create basic test
echo "🧪 Creating basic test..."
cat > tests/Functional/ApiTest.php << 'EOF'
<?php

namespace App\Tests\Functional;

use ApiPlatform\Symfony\Bundle\Test\ApiTestCase;
use App\Entity\User;

class ApiTest extends ApiTestCase
{
    public function testGetTasks(): void
    {
        $client = self::createClient();
        
        // Get JWT token
        $response = $client->request('POST', '/api/login_check', [
            'json' => [
                'email' => 'user@example.com',
                'password' => 'user123',
            ],
        ]);

        $token = $response->toArray()['token'];

        // Test getting tasks
        $client->request('GET', '/api/tasks', [
            'headers' => [
                'Authorization' => "Bearer $token",
            ],
        ]);

        $this->assertResponseIsSuccessful();
        $this->assertResponseHeaderSame('content-type', 'application/ld+json; charset=utf-8');
    }

    public function testCreateTask(): void
    {
        $client = self::createClient();
        
        // Get JWT token
        $response = $client->request('POST', '/api/login_check', [
            'json' => [
                'email' => 'user@example.com',
                'password' => 'user123',
            ],
        ]);

        $token = $response->toArray()['token'];

        // Create a task
        $client->request('POST', '/api/tasks', [
            'headers' => [
                'Authorization' => "Bearer $token",
            ],
            'json' => [
                'title' => 'Test Task',
                'description' => 'Test Description',
            ],
        ]);

        $this->assertResponseIsSuccessful();
        $this->assertResponseHeaderSame('content-type', 'application/ld+json; charset=utf-8');
        $this->assertJsonContains([
            'title' => 'Test Task',
            'description' => 'Test Description',
            'completed' => false,
        ]);
    }
}
EOF

# Set proper permissions
echo "🔐 Setting permissions..."
chmod -R 755 .
chown -R www-data:www-data var

echo "✅ Symfony API Platform project created successfully!"
echo ""
echo "🌐 API Documentation: http://localhost:8000/api/docs"
echo "🔑 Test users:"
echo "   Admin: admin@example.com / admin123"
echo "   User: user@example.com / user123"
echo ""
echo "🚀 Run 'php bin/console server:run' to start the development server"